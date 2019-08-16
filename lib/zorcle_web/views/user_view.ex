defmodule ZorcleWeb.UserView do
  use ZorcleWeb, :view

  alias Zorcle.Accounts

  def first_name(%Accounts.User{name: name}) do
    name
    |> String.split(" ")
    |> Enum.at(0)
  end
end
