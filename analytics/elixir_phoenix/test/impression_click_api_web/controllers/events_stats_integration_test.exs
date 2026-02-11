defmodule ImpressionClickAPIWeb.EventsStatsIntegrationTest do
  use ImpressionClickAPIWeb.ConnCase

  defp event_payload(overrides \\ %{}) do
    Map.merge(
      %{
        "event_id" => Ecto.UUID.generate(),
        "type" => "impression",
        "campaign_id" => "camp_123",
        "creative_id" => "cr_456",
        "source" => "web",
        "occurred_at" => "2026-02-10T21:10:00Z",
        "user_id" => "u_999",
        "metadata" => %{"ip" => "1.2.3.4"}
      },
      overrides
    )
  end

  test "POST /events accepts valid payload", %{conn: conn} do
    conn = post(conn, "/events", event_payload())

    assert response(conn, 202)
  end

  test "POST /events rejects invalid payload", %{conn: conn} do
    payload = event_payload(%{"type" => "unsupported"})
    conn = post(conn, "/events", payload)

    assert %{"errors" => %{"type" => _}} = json_response(conn, 422)
  end

  test "GET /stats returns ordered minute series with expected counts", %{conn: conn} do
    assert response(
             post(conn, "/events", event_payload(%{"event_id" => Ecto.UUID.generate()})),
             202
           )

    assert response(
             post(
               build_conn(),
               "/events",
               event_payload(%{"event_id" => Ecto.UUID.generate(), "type" => "click"})
             ),
             202
           )

    assert response(
             post(
               build_conn(),
               "/events",
               event_payload(%{
                 "event_id" => Ecto.UUID.generate(),
                 "occurred_at" => "2026-02-10T21:11:10Z"
               })
             ),
             202
           )

    stats_conn =
      get(
        build_conn(),
        "/stats",
        %{
          "campaign_id" => "camp_123",
          "from" => "2026-02-10T21:10:00Z",
          "to" => "2026-02-10T21:11:00Z",
          "granularity" => "minute"
        }
      )

    assert %{
             "series" => [
               %{"ts" => "2026-02-10T21:10:00Z", "impressions" => 1, "clicks" => 1},
               %{"ts" => "2026-02-10T21:11:00Z", "impressions" => 1, "clicks" => 0}
             ]
           } = json_response(stats_conn, 200)
  end
end
