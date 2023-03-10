defmodule Auriga.Presentations.Presentation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "presentations" do
    field :title, :string
    belongs_to :user, Auriga.Accounts.User
    has_many :slides, Auriga.Presentations.Slide

    timestamps()
  end

  @doc false
  def changeset(presentation, attrs \\ %{}) do
    presentation
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
