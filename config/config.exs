# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :auriga,
  ecto_repos: [Auriga.Repo]

# Configures the endpoint
config :auriga, AurigaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "hHFL9fxTwx2BuH47ML3u0g3BYAY7u/MkYniGFqf/nkK4cfzbvZKFDLVV6UbpDZdg",
  render_errors: [view: AurigaWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Auriga.PubSub,
  live_view: [signing_salt: "yhV39XTJ"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
