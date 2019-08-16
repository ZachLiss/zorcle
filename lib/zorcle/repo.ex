defmodule Zorcle.Repo do
  use Ecto.Repo,
    otp_app: :zorcle,
    adapter: Ecto.Adapters.Postgres
end
