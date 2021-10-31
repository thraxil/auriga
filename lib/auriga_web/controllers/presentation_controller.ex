import Ecto.Query, only: [from: 2]

defmodule AurigaWeb.PresentationController do
  alias Auriga.Accounts
  alias AurigaWeb.UserAuth
  alias Auriga.Repo
  alias Auriga.Presentations.Presentation
  use AurigaWeb, :controller
  require Logger

  def index(conn, _params) do
    query = from p in Ecto.assoc(conn.assigns.current_user, :presentations),
      order_by: [desc: :inserted_at]
    presentations = Repo.all(query)
    
    render conn, "index.html", presentations: presentations
  end

  def show(conn, %{"id" => id}) do
    presentation = Repo.get(Presentation, id) |> Repo.preload(:user)
    render conn, "show.html", presentation: presentation
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

  def delete(conn, _params) do
  end
end
