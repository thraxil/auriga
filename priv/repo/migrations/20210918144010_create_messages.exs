defmodule Auriga.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :room_id, references(:rooms), null: false
      add :type, :string, null: false
      add :user_id, references(:users)
      add :content_md, :text
      add :content_html, :text

      timestamps()
    end

    create index(:messages, [:room_id])
    create index(:messages, [:user_id])
  end
end
