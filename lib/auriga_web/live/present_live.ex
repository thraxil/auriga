import Ecto.Query, only: [from: 2, first: 2]

defmodule AurigaWeb.PresentLive do
  use AurigaWeb, :live_view
  use Timex
  require Logger

  alias Auriga.Accounts
  alias Auriga.Accounts.User
  alias Auriga.Presentations
  alias Auriga.Presentations.Presentation
  alias Auriga.Repo

  defp find_current_user(session) do
    with user_token when not is_nil(user_token) <- session["user_token"],
         %User{} = user <- Accounts.get_user_by_session_token(user_token),
         do: user
  end

  @impl true
  def mount(%{"id" => presentation_id}, session, socket) do
    topic = "presentation:" <> presentation_id
    current_user = find_current_user(session)

    presentation =
      Repo.get_by(Presentation, id: presentation_id)
      |> Repo.preload(:user)

    slides_count = Presentations.presentation_slides_count(presentation)

    query = first(Ecto.assoc(presentation, :slides), :index)
    slide = Repo.one(query)

    Logger.info(slide)

    if connected?(socket) do
      AurigaWeb.Endpoint.subscribe(topic)
      AurigaWeb.Presence.track(self(), topic, current_user.email, %{})
    end

    {:ok,
     assign(socket,
       presentation_id: presentation_id,
       topic: topic,
       presentation: presentation,
       current_user: current_user,
       user_list: [],
       offset: 1,
       slide: slide,
       count: slides_count
     )}
  end

  @impl true
  def handle_event("forward", _params, socket) do
    offset = min(socket.assigns.offset + 1, socket.assigns.count)
    presentation = socket.assigns.presentation

    query =
      from s in Ecto.assoc(presentation, :slides),
        order_by: :index,
        offset: ^(offset - 1),
        limit: 1

    slide = Repo.one(query)

    AurigaWeb.Endpoint.broadcast(socket.assigns.topic, "set-slide", %{
      offset: offset,
      slide: slide
    })

    {:noreply, socket}
  end

  def handle_event("back", _params, socket) do
    offset = max(socket.assigns.offset - 1, 1)
    presentation = socket.assigns.presentation

    query =
      from s in Ecto.assoc(presentation, :slides),
        order_by: :index,
        offset: ^(offset - 1),
        limit: 1

    slide = Repo.one(query)

    AurigaWeb.Endpoint.broadcast(socket.assigns.topic, "set-slide", %{
      offset: offset,
      slide: slide
    })

    {:noreply, assign(socket, offset: offset, slide: slide)}
  end

  @impl true
  def handle_info(%{event: "presence_diff", payload: %{joins: _joins, leaves: _leaves}}, socket) do
    user_list = AurigaWeb.Presence.list(socket.assigns.topic) |> Map.keys()
    {:noreply, assign(socket, user_list: user_list)}
  end

  def handle_info(%{event: "set-slide", payload: %{offset: offset, slide: slide}}, socket) do
    {:noreply, assign(socket, slide: slide, offset: offset)}
  end
end
