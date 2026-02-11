defmodule ImpressionClickAPI.Events.RawEvent do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "events_raw" do
    field :event_id, :string
    field :type, :string
    field :campaign_id, :string
    field :creative_id, :string
    field :source, :string
    field :occurred_at, :utc_datetime
    field :user_id, :string
    field :metadata, :map

    timestamps(type: :utc_datetime)
  end

  @required_fields ~w(event_id type campaign_id source occurred_at)a
  @optional_fields ~w(creative_id user_id metadata)a
  @event_types ~w(impression click)

  def changeset(raw_event, attrs) do
    raw_event
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:type, @event_types)
  end
end
