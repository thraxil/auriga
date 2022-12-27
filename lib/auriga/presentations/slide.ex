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

  @doc false
  def changeset(slide, attrs \\ %{}) do
    slide
    |> cast(attrs, [:title, :index, :content_md, :notes_md])
    |> validate_required([:title, :content_md])
    |> gen_notes
    |> gen_content
  end

  defp gen_notes(%{valid?: true, changes: %{notes_md: notes}} = changeset) do
    put_change(changeset, :notes_html, AlchemistMarkdown.to_html(notes))
  end

  defp gen_notes(changeset), do: changeset

  defp gen_content(%{valid?: true, changes: %{content_md: content}} = changeset) do
    put_change(changeset, :content_html, AlchemistMarkdown.to_html(content))
  end

  defp gen_content(changeset), do: changeset
end
