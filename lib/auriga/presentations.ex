defmodule Auriga.Presentations do
  @moduledoc """
  The Presentations context.
  """

  import Ecto.Changeset, only: [change: 2]
  import Ecto.Query, warn: false
  alias Auriga.Repo

  alias Auriga.Presentations.Presentation
  alias Auriga.Presentations.Slide

  def list_presentations do
    Repo.all(Presentation)
  end

  def list_user_presentations(user) do
    query = from p in Ecto.assoc(user, :presentations),
      order_by: [desc: :inserted_at]
    Repo.all(query)
  end

  def get_presentation!(id) do
    Repo.get!(Presentation, id)
    |> Repo.preload(:user)
  end

  def get_slide!(id) do
    Repo.get!(Slide, id)
    |> Repo.preload(:presentation)
  end

  def add_slide(presentation, slide_params) do
    changeset =
      presentation
      |> Ecto.build_assoc(:slides)
      |> Slide.changeset(slide_params)
    Repo.insert(changeset)
  end

  def set_slide_index!(slide, idx) do
    Repo.update!(change(slide, index: idx))
  end
  
  def normalize_slide_indexes(presentation) do
    Repo.transaction(fn ->
      get_presentation_slides(presentation)
      |> Enum.with_index
      |> Enum.map(fn {slide, idx} -> set_slide_index!(slide, idx + 1) end)
    end)
  end

  def delete_slide(presentation, slide_id) do
    {:ok, _} = Repo.get_by!(Slide, [id: slide_id, presentation_id: presentation.id])
    |> Repo.delete()
    normalize_slide_indexes(presentation)
  end
  
  def get_presentation_slides(presentation) do
    Repo.all(from s in Ecto.assoc(presentation, :slides),
      order_by: :index)
  end

  def presentation_slides_count(presentation) do
    presentation |> Ecto.assoc(:slides) |> Repo.aggregate(:count, :id)
  end

  def create_presentation(attrs \\ %{}) do
    %Presentation{}
    |> Presentation.changeset(attrs)
    |> Repo.insert()
  end

  def create_user_presentation(user, presentation_params) do
    changeset =
      user
      |> Ecto.build_assoc(:presentations)
      |> Presentation.changeset(presentation_params)
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
