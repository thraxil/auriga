defmodule Auriga.Presentations do
  @moduledoc """
  The Presentations context.
  """

  import Ecto.Query, warn: false
  alias Auriga.Repo

  alias Auriga.Presentations.Presentation
  alias Auriga.Presentations.Slide

  def list_presentations do
    Repo.all(Presentation)
  end

  def get_presentation!(id) do
    Repo.get!(Presentation, id)
    |> Repo.preload(:user)
  end

  def get_slide!(id) do
    Repo.get!(Slide, id)
    |> Repo.preload(:presentation)
  end
  
  def get_presentation_slides(presentation) do
    Repo.all(from s in Ecto.assoc(presentation, :slides),
      order_by: :index)
  end

  def create_presentation(attrs \\ %{}) do
    %Presentation{}
    |> Presentation.changeset(attrs)
    |> Repo.insert()
  end

  def update_presentation(%Presentation{} = presentation, attrs) do
    presentation
    |> Presentation.changeset(attrs)
    |> Repo.update()
  end

  def delete_presentation(%Presentation{} = presentation) do
    Repo.delete(presentation)
  end

  def change_presentation(%Presentation{} = presentation, attrs \\ %{}) do
    Presentation.changeset(presentation, attrs)
  end
end
