defmodule Auriga.Repo.Migrations.CreatePresentations do
  use Ecto.Migration

  def change do
    create table(:presentations) do
      add :title, :string
      add :user, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:presentations, [:user])
  end
end
