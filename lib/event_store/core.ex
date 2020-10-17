defmodule EventStore.Core do
  import Ecto.Query, warn: false
  import Ecto.Changeset

  alias EventStore.Repo
  alias __MODULE__.Event

  @doc """
  create a domain event.
  """
  def create_event(dto) do
    with {:ok, changeset} <- validate_event(dto),
         {:ok, event} <- persist(changeset, :insert) do
      {:ok, event}
    else
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  list events.
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

  @required_fields ~w(stream_name type data metadata)a

  defp event_changeset(%Event{} = event, attrs) do
    event
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    # Acts as list
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

  defp max_position(scope_value) do
    scope_value
    |> max_position_query()
    |> Repo.one() || 0
  end

  defp max_position_query(scope_value) do
    scope = :stream_name
    from(r in Event, where: field(r, ^scope) == ^scope_value, select: max(r.position))
  end

  # END Acts as list

  # No need for preload
  defp list_events_query(criteria) do
    query = from(p in Event)

    Enum.reduce(criteria, query, fn
      {:limit, limit}, query ->
        from(p in query, limit: ^limit)

      {:offset, offset}, query ->
        from(p in query, offset: ^offset)

      {:order, order}, query ->
        from(p in query, order_by: [{^order, ^:global_position}])

      _arg, query ->
        query
    end)
  end
end
