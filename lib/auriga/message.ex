defmodule Auriga.Message do
  use Ecto.Schema

  schema "messages" do
    field :type, :string, default: "user"
    belongs_to :user, Auriga.Accounts.User
    belongs_to :room, Auriga.Room
    field :content_md, :string
    field :content_html, :string

    timestamps()
  end
end
