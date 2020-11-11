defmodule EventStore.Core do
  import Ecto.Query, warn: false
  import Ecto.Changeset

  alias EventStore.Repo
  alias __MODULE__.{Event, Dispatcher}

  @doc """
  create a domain event.
  """
  def create_event(dto) do
    with {:ok, changeset} <- validate_event(dto),
         {:ok, event} <- persist(changeset, :insert),
         :ok <- Dispatcher.dispatch(event) do
      {:ok, event}
    else
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  list events.

  filters:
    * stream_name
    * type
    * gt_than_global
    * gt_than_position
    * metadata
    * data
    * before
    * after

  # Example:

  Core.list_events order: :asc, filter: [type: "test"]

  Core.list_events filter: [
    metadata: [
      {"user_id", "5b834fd4-b7f3-41af-9197-99bfb589950c"},
      {"trace_id", "6db9b5e2-d70f-40e9-8f47-8994f89a6890"}
    ],
    before: Date.utc_today()
  ]
  """
  def list_events(criteria \\ []) do
    criteria
    |> list_events_query()
    |> Repo.all()
  end

  @doc """
  get event by id.
  """
  def get_event(id) do
    Repo.get(Event, id)
  end

  @doc """
  Returns max of global position.
  """
  def max_global_position() do
    max_global_position_query()
    |> Repo.one() || 0
  end

  @doc """
  Returns max of position, per stream_name.
  """
  def max_position(scope_value) do
    scope_value
    |> max_position_query()
    |> Repo.one() || 0
  end

  # Private

  defp validate_event(dto) do
    validate_event(%Event{}, dto)
  end

  defp validate_event(event, dto) do
    case event_changeset(event, dto) do
      %{valid?: true} = changeset -> {:ok, changeset}
      %{valid?: false} = changeset -> {:error, changeset}
    end
  end

  defp persist(valid_changeset, :insert) do
    Repo.insert(valid_changeset)
  end

  # Private changeset

  @required_fields ~w(stream_name type data metadata)a

  defp event_changeset(%Event{} = event, attrs) do
    event
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> generate_position()
  end

  # Acts as list
  #
  # Use changeset.changes when creating a new event
  # Use changeset.data if updating...
  defp generate_position(
         %Ecto.Changeset{valid?: true, changes: %{stream_name: stream_name}} = changeset
       ) do
    position = max_position(stream_name) + 1
    put_change(changeset, :position, position)
  end

  defp generate_position(changeset), do: changeset

  defp max_position_query(scope_value) do
    scope = :stream_name
    from(r in Event, where: field(r, ^scope) == ^scope_value, select: max(r.position))
  end

  # END Acts as list

  defp max_global_position_query() do
    from(r in Event, select: max(r.global_position))
  end

  # No need for preload
  defp list_events_query(criteria) do
    query = from(p in Event)

    Enum.reduce(criteria, query, fn
      {:limit, limit}, query ->
        from(p in query, limit: ^limit)

      {:offset, offset}, query ->
        from(p in query, offset: ^offset)

      {:filter, filters}, query ->
        filter_with(filters, query)

      {:order, order}, query ->
        from(p in query, order_by: [{^order, ^:global_position}])

      _arg, query ->
        query
    end)
  end

  defp filter_with(filters, query) do
    Enum.reduce(filters, query, fn
      {:stream_name, stream_name}, query ->
        pattern = "%#{stream_name}%"
        from(q in query, where: ilike(q.stream_name, ^pattern))

      {:gt_than_global, gp}, query ->
        from(q in query, where: q.global_position > ^gp)

      {:gt_than_position, position}, query ->
        from(q in query, where: q.position > ^position)

      {:type, type}, query ->
        from(q in query, where: q.type == ^type)

      # Date query
      {:before, date}, query ->
        from(q in query, where: fragment("?::date", q.inserted_at) <= ^date)

      {:after, date}, query ->
        from(q in query, where: fragment("?::date", q.inserted_at) > ^date)

      # JsonB filtering
      #
      # This allow filtering like
      # EventStore.list_events filter: [
      #  metadata: [{"user_id", "5b834fd4-b7f3-41af-9197-99bfb589950c"}, {"trace_id", "6db9b5e2-d70f-40e9-8f47-8994f89a6890"}]
      # ]
      {:metadata, metadata_keyword}, query ->
        Enum.reduce(metadata_keyword, query, fn
          {key, value}, subquery ->
            from(q in subquery, where: fragment("metadata -> ? = ?", ^key, ^value))
        end)

      {:data, data_keyword}, query ->
        Enum.reduce(data_keyword, query, fn
          {key, value}, subquery ->
            from(q in subquery, where: fragment("data -> ? = ?", ^key, ^value))
        end)

      _arg, query ->
        query
    end)
  end
end
