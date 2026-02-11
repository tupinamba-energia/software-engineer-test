defmodule ImpressionClickAPIWeb.EventsController do
  use ImpressionClickAPIWeb, :controller

  alias ImpressionClickAPI.Events.RawEvent
  alias ImpressionClickAPI.Repo

  @required_fields ["event_id", "type", "campaign_id", "source", "occurred_at"]

  def create(conn, params) do
    try do
      with :ok <- validate_required_fields(params),
           :ok <- validate_type(params["type"]),
           {:ok, occurred_at, _} <- DateTime.from_iso8601(params["occurred_at"]),
           :ok <- validate_utc(occurred_at) do
        attrs = %{
          event_id: params["event_id"],
          type: params["type"],
          campaign_id: params["campaign_id"],
          creative_id: params["creative_id"],
          source: params["source"],
          occurred_at: DateTime.truncate(occurred_at, :second),
          user_id: params["user_id"],
          metadata: params["metadata"]
        }

        case Repo.insert(RawEvent.changeset(%RawEvent{}, attrs)) do
          {:ok, _event} ->
            send_resp(conn, :accepted, "")

          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{errors: changeset_errors(changeset)})
        end
      else
        {:error, :missing_fields, fields} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: %{required: fields}})

        {:error, :invalid_type} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: %{type: ["must be impression or click"]}})

        {:error, :invalid_occurred_at} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: %{occurred_at: ["must be a valid ISO8601 UTC datetime"]}})

        _ ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: %{payload: ["invalid payload"]}})
      end
    rescue
      _ ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "internal server error"})
    end
  end

  defp validate_required_fields(params) when is_map(params) do
    missing =
      Enum.filter(@required_fields, fn key -> is_nil(params[key]) or params[key] == "" end)

    case missing do
      [] -> :ok
      fields -> {:error, :missing_fields, fields}
    end
  end

  defp validate_required_fields(_), do: {:error, :missing_fields, @required_fields}

  defp validate_type("impression"), do: :ok
  defp validate_type("click"), do: :ok
  defp validate_type(_), do: {:error, :invalid_type}

  defp validate_utc(%DateTime{utc_offset: 0, std_offset: 0}), do: :ok
  defp validate_utc(_), do: {:error, :invalid_occurred_at}

  defp changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%\{(\w+)\}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
