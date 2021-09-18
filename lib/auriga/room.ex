defmodule Auriga.Room do
  use Ecto.Schema

  schema "rooms" do
    field :name, :string
    field :slug, :string
    belongs_to :user, Auriga.Accounts.User
  end
end
