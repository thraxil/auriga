defmodule Auriga.Presentations.Slide do
  use Ecto.Schema
  import Ecto.Changeset

  schema "slides" do
    field :title, :string
    belongs_to :presentation, Auriga.Presentations.Presentation

    field :index, :integer

    field :content_md, :string
    field :content_html, :string

    field :notes_md, :string
    field :notes_html, :string

    timestamps()
  end
end
