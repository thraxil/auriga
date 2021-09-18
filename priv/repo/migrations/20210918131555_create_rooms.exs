defmodule Auriga.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :user_id, references(:users)
    end

    create unique_index(:rooms, [:slug])
  end
end
