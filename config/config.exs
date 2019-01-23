use Mix.Config

config :olivia, OliviaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "po4C5BMidMUgoCWobtDqWrNNklWGB8Y3BqCZDraQBDB9KI3U6efR2HUMDkGx5gQ8",
  render_errors: [view: OliviaWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Olivia.PubSub, adapter: Phoenix.PubSub.PG2],
  http: [port: {:system, "PORT"}]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

import_config "#{Mix.env()}.exs"
