defmodule ImpressionClickAPI.Repo.Migrations.CreateEventsRaw do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS pgcrypto", "DROP EXTENSION IF EXISTS pgcrypto")

    create table(:events_raw, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")
      add :event_id, :string, null: false
      add :type, :string, null: false
      add :campaign_id, :string, null: false
      add :creative_id, :string
      add :source, :string, null: false
      add :occurred_at, :utc_datetime, null: false
      add :user_id, :string
      add :metadata, :map
      timestamps(type: :utc_datetime)
    end
  end
end
