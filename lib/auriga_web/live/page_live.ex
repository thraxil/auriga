import Ecto.Query

defmodule AurigaWeb.PageLive do
  use AurigaWeb, :live_view
  alias Auriga.Room
  alias Auriga.Accounts
  alias Auriga.Accounts.User
  alias Auriga.Repo
  require Logger

  defp find_current_user(session) do
    with user_token when not is_nil(user_token) <- session["user_token"],
         %User{} = user <- Accounts.get_user_by_session_token(user_token),
         do: user
  end

  @impl true
  def mount(_params, session, socket) do    
    current_user = find_current_user(session)    
    Logger.info(current_user.email)

    owned_rooms = Repo.all(
      from r in Ecto.assoc(current_user, :rooms),
      order_by: [asc: :name])

    # i know this is a really inefficient way of doing this query
    # improve it once I understand ecto better.
    active_rooms = Repo.all(from m in Ecto.assoc(current_user, :messages), order_by: [asc: :type], distinct: m.room_id)
    |> Enum.map(fn msg -> msg.room_id end)
    |> Enum.map(fn id -> Repo.get(Room, id) end)
    
    {:ok, assign(socket, current_user: current_user, owned_rooms: owned_rooms, active_rooms: active_rooms)}
  end

  @impl true
  def handle_event("random-room", _data, socket) do
    random_slug = MnemonicSlugs.generate_slug(4)
    Logger.info(random_slug)
    Repo.insert!(%Room{name: random_slug, slug: random_slug, user: socket.assigns.current_user})
    {:noreply, push_redirect(socket, to: "/chat/" <> random_slug)}
  end
end
