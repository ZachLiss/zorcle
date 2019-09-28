defmodule Zorcle.MagicLinks do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  # DO NOT DO IN PRODUCTION
  @salt "magic"

  def create_token(%{name: name, email: email} = user) do
    token = Phoenix.Token.sign(ZorcleWeb.Endpoint, @salt, "#{name}-#{email}")
    Agent.update(__MODULE__, fn map -> Map.put(map, token, user) end)
    token
  end

  def verify_token(token) do
    case Agent.get_and_update(__MODULE__, fn map -> Map.pop(map, token) end) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end
end
