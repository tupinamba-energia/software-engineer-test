defmodule ImpressionClickAPIWeb.Router do
  use ImpressionClickAPIWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ImpressionClickAPIWeb do
    pipe_through :api

    post "/events", EventsController, :create
    get "/stats", StatsController, :index
  end
end
