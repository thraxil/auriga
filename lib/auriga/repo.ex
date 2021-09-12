defmodule Auriga.Repo do
  use Ecto.Repo,
    otp_app: :auriga,
    adapter: Ecto.Adapters.Postgres
end
