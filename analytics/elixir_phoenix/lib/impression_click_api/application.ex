defmodule ImpressionClickAPI.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ImpressionClickAPIWeb.Telemetry,
      ImpressionClickAPI.Repo,
      {DNSCluster,
       query: Application.get_env(:impression_click_api, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ImpressionClickAPI.PubSub},
      # Start a worker by calling: ImpressionClickAPI.Worker.start_link(arg)
      # {ImpressionClickAPI.Worker, arg},
      # Start to serve requests, typically the last entry
      ImpressionClickAPIWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ImpressionClickAPI.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ImpressionClickAPIWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
