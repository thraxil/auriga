defmodule Auriga.Repo.Migrations.RenamePresentationUser do
  use Ecto.Migration

  def change do
    rename table(:presentations), :user, to: :user_id
  end
end
