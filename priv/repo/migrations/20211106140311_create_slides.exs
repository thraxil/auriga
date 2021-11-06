defmodule Auriga.Repo.Migrations.CreateSlides do
  use Ecto.Migration

  def change do
    create table(:slides) do
      add :presentation_id, references(:presentations), null: false
      add :index, :integer
      add :title, :string
      add :content_md, :string
      add :content_html, :string
      add :notes_md, :string
      add :notes_html, :string
      timestamps()
    end
    create index(:slides, [:presentation_id])
  end
end
