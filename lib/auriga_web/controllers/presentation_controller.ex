import Ecto.Query, only: [from: 2]

defmodule AurigaWeb.PresentationController do
  alias Auriga.Accounts
  alias AurigaWeb.UserAuth
  alias Auriga.Repo
  alias Auriga.Presentations
  alias Auriga.Presentations.Presentation
  alias Auriga.Presentations.Slide
  use AurigaWeb, :controller
  require Logger

  def index(conn, _params) do
    presentations = Presentations.list_user_presentations(conn.assigns.current_user)
    render conn, "index.html", presentations: presentations
  end

  def show(conn, %{"id" => id}) do
    presentation = Presentations.get_presentation!(id)
    slides = Presentations.get_presentation_slides(presentation)
    slide_changeset = Slide.changeset(%Slide{})
    slides_count = Presentations.presentation_slides_count(presentation)
    render conn, "show.html", presentation: presentation, slides: slides,
      slide_changeset: slide_changeset, slides_count: slides_count,
      next_slide_index: slides_count + 1
  end

  def add_slide(conn, %{"id" => id, "slide" => slide_params}) do
    presentation = Presentations.get_presentation!(id)
    changeset =
      presentation
      |> Ecto.build_assoc(:slides)
      |> Slide.changeset(slide_params)
    case Repo.insert(changeset) do
      {:ok, slide} ->
        conn
        |> put_flash(:info, "slide added")
        |> redirect(to: Routes.presentation_path(conn, :show, presentation))
      {:error, changeset} ->
        slides = Presentations.get_presentation_slides(presentation)    
        render conn, "show.html", presentation: presentation, slides: slides, slide_changeset: changeset
    end
  end

  def delete_slide(conn, %{"id" => presentation_id, "slide_id" => slide_id}) do
    presentation = Presentations.get_presentation!(presentation_id)
    # TODO: check that slide is attached to presentation
    slide = Presentations.get_slide!(slide_id)
    # TODO: update indexes
    {:ok, _} = Repo.delete slide
    conn
    |> put_flash(:info, "slide deleted")
    |> redirect(to: Routes.presentation_path(conn, :show, presentation))
  end

  def new(conn, _params) do
    changeset = Presentation.changeset(%Presentation{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"presentation" => presentation_params}) do
    changeset =
      conn.assigns.current_user
      |> Ecto.build_assoc(:presentations)
      |> Presentation.changeset(presentation_params)
    case Repo.insert(changeset) do
      {:ok, presentation} ->
        conn
        |> put_flash(:info, "presentation created")
        |> redirect(to: Routes.presentation_path(conn, :show, presentation))
      {:error, changeset} ->
        render conn, "new.html", changeset: changeset
    end
  end

  def delete(conn, %{"id" => id}) do
    presentation = Repo.get(Presentation, id)
    {:ok, _} = Repo.delete presentation
    conn
    |> put_flash(:info, "presentation deleted")
    |> redirect(to: Routes.presentation_path(conn, :index))
  end
end
