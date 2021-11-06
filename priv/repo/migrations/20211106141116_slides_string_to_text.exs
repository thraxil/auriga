defmodule Auriga.Repo.Migrations.SlidesStringToText do
  use Ecto.Migration

  def change do
    alter table(:slides) do
      modify :content_md, :text
      modify :content_html, :text
      modify :notes_md, :text
      modify :notes_html, :text
    end
  end
end
