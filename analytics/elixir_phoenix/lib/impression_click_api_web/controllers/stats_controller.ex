defmodule ImpressionClickAPIWeb.StatsController do
  use ImpressionClickAPIWeb, :controller

  import Ecto.Query

  alias ImpressionClickAPI.Events.RawEvent
  alias ImpressionClickAPI.Repo

  @required_fields ["campaign_id", "from", "to", "granularity"]

  def index(conn, params) do
    try do
      with :ok <- validate_required_fields(params),
           :ok <- validate_granularity(params["granularity"]),
           {:ok, from, _} <- DateTime.from_iso8601(params["from"]),
           {:ok, to, _} <- DateTime.from_iso8601(params["to"]),
           :ok <- validate_time_range(from, to) do
        from_ts = truncate_to_minute(from)
        to_ts = truncate_to_minute(to)
        to_end_of_minute = DateTime.add(to_ts, 59, :second)

        events =
          from(event in RawEvent,
            where:
              event.campaign_id == ^params["campaign_id"] and
                event.occurred_at >= ^from_ts and
                event.occurred_at <= ^to_end_of_minute,
            order_by: [asc: event.occurred_at],
            select: %{occurred_at: event.occurred_at, type: event.type}
          )
          |> Repo.all()

        series =
          events
          |> Enum.reduce(%{}, fn event, acc ->
            minute = truncate_to_minute(event.occurred_at)
            key = DateTime.to_iso8601(minute)

            counts = Map.get(acc, key, %{ts: key, impressions: 0, clicks: 0})

            updated =
              case event.type do
                "click" -> %{counts | clicks: counts.clicks + 1}
                _ -> %{counts | impressions: counts.impressions + 1}
              end

            Map.put(acc, key, updated)
          end)
          |> Map.values()
          |> Enum.sort_by(& &1.ts)

        json(conn, %{
          campaign_id: params["campaign_id"],
          from: DateTime.to_iso8601(from),
          to: DateTime.to_iso8601(to),
          granularity: "minute",
          series: series
        })
      else
        {:error, :missing_fields, fields} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: %{required: fields}})

        {:error, :invalid_granularity} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: %{granularity: ["must be minute"]}})

        {:error, :invalid_time_range} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: %{from: ["must be less than or equal to to"]}})

        _ ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: %{query: ["invalid query"]}})
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

  defp validate_granularity("minute"), do: :ok
  defp validate_granularity(_), do: {:error, :invalid_granularity}

  defp validate_time_range(from, to) do
    if DateTime.compare(from, to) == :gt do
      {:error, :invalid_time_range}
    else
      :ok
    end
  end

  defp truncate_to_minute(%DateTime{} = date_time) do
    %DateTime{} = truncated = DateTime.truncate(date_time, :second)
    %DateTime{truncated | second: 0, microsecond: {0, 0}}
  end
end
