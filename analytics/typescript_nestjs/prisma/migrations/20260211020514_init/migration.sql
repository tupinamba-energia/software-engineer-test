-- CreateTable
CREATE TABLE "public"."events_raw" (
    "id" UUID NOT NULL,
    "event_id" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "campaign_id" TEXT NOT NULL,
    "creative_id" TEXT,
    "source" TEXT NOT NULL,
    "occurred_at" TIMESTAMP(3) NOT NULL,
    "user_id" TEXT,
    "metadata" JSONB,
    "inserted_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "events_raw_pkey" PRIMARY KEY ("id")
);
