defmodule AurigaWeb.PresentationController do
  alias Auriga.Presentations
  alias Auriga.Presentations.Presentation
  alias Auriga.Presentations.Slide
  use AurigaWeb, :controller
  require Logger

  def index(conn, _params) do
    presentations = Presentations.list_user_presentations(conn.assigns.current_user)
    render(conn, "index.html", presentations: presentations)
  end

  def show(conn, %{"id" => id}) do
    presentation = Presentations.get_presentation!(id)
    slides = Presentations.get_presentation_slides(presentation)
    slide_changeset = Slide.changeset(%Slide{})
    slides_count = Presentations.presentation_slides_count(presentation)

    render(conn, "show.html",
      presentation: presentation,
      slides: slides,
      slide_changeset: slide_changeset,
      slides_count: slides_count,
      next_slide_index: slides_count + 1
    )
  end

  def add_slide(conn, %{"id" => id, "slide" => slide_params}) do
    presentation = Presentations.get_presentation!(id)

    case Presentations.add_slide(presentation, slide_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "slide added")
        |> redirect(to: Routes.presentation_path(conn, :show, presentation))

      {:error, changeset} ->
        slides = Presentations.get_presentation_slides(presentation)
        slides_count = Presentations.presentation_slides_count(presentation)

        render(conn, "show.html",
          presentation: presentation,
          slides: slides,
          slide_changeset: changeset,
          slides_count: slides_count,
          next_slide_index: slides_count + 1
        )
    end
  end

  def delete_slide(conn, %{"id" => presentation_id, "slide_id" => slide_id}) do
    presentation = Presentations.get_presentation!(presentation_id)
    {:ok, _} = Presentations.delete_slide(presentation, slide_id)

    conn
    |> put_flash(:info, "slide deleted")
    |> redirect(to: Routes.presentation_path(conn, :show, presentation))
  end

  def new(conn, _params) do
    changeset = Presentation.changeset(%Presentation{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"presentation" => presentation_params}) do
    case Presentations.create_user_presentation(conn.assigns.current_user, presentation_params) do
      {:ok, presentation} ->
        conn
        |> put_flash(:info, "presentation created")
        |> redirect(to: Routes.presentation_path(conn, :show, presentation))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    presentation = Presentations.get_presentation!(id)
    {:ok, _} = Presentations.delete_presentation(presentation)

    conn
    |> put_flash(:info, "presentation deleted")
    |> redirect(to: Routes.presentation_path(conn, :index))
  end

  def show_slide(conn, %{"id" => presentation_id, "slide_id" => slide_id}) do
    presentation = Presentations.get_presentation!(presentation_id)
    slide = Presentations.get_slide!(slide_id)
    # TODO: should be able to assert that the presentation and slide
    # match.
    slides = Presentations.get_presentation_slides(presentation)
    slide_changeset = Slide.changeset(slide)
    slides_count = Presentations.presentation_slides_count(presentation)

    render(conn, "show_slide.html",
      presentation: presentation,
      slide: slide,
      slides: slides,
      slide_changeset: slide_changeset,
      slides_count: slides_count,
      next_slide_index: slides_count + 1
    )
  end

  def edit_slide(conn, %{"id" => presentation_id, "slide_id" => slide_id, "slide" => slide_params}) do
    _presentation = Presentations.get_presentation!(presentation_id)
    slide = Presentations.get_slide!(slide_id)

    case Presentations.update_slide(slide, slide_params) do
      {:ok, slide} ->
        conn
        |> put_flash(:info, "slide updated")
        |> redirect(to: Routes.presentation_path(conn, :show, slide.presentation))

      {:error, changeset} ->
        render(conn, "show_slide.html", changeset: changeset)
    end
  end
end
