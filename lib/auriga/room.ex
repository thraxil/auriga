defmodule Auriga.Room do
  use Ecto.Schema

  schema "rooms" do
    field :name, :string
    field :slug, :string
    belongs_to :user, Auriga.Accounts.User
    has_many :messages, Auriga.Message
  end
end
