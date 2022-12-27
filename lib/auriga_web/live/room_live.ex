import Ecto.Query, only: [from: 2]

defmodule AurigaWeb.RoomLive do
  use AurigaWeb, :live_view
  use Timex
  require Logger

  alias Auriga.Accounts
  alias Auriga.Accounts.User
  alias Auriga.Room
  alias Auriga.Repo
  alias Auriga.Message

  defp find_current_user(session) do
    with user_token when not is_nil(user_token) <- session["user_token"],
         %User{} = user <- Accounts.get_user_by_session_token(user_token),
         do: user
  end

  defp m_to_message(%Message{type: "system", content_html: content_html, inserted_at: inserted_at}) do
    %{type: :system, content: content_html, inserted_at: inserted_at}
  end

  defp m_to_message(%Message{
         type: "user",
         content_html: content_html,
         inserted_at: inserted_at,
         user: user
       }) do
    %{type: :user, content: content_html, inserted_at: inserted_at, email: user.email}
  end

  @impl true
  def mount(%{"id" => room_id}, session, socket) do
    topic = "room:" <> room_id
    current_user = find_current_user(session)
    room = Repo.get_by(Room, slug: room_id)

    query =
      from m in Ecto.assoc(room, :messages),
        order_by: [desc: :inserted_at],
        preload: :user,
        limit: 10

    messages =
      Repo.all(query)
      |> Enum.map(fn m -> m_to_message(m) end)
      |> Enum.reverse()

    Logger.info(messages)

    if connected?(socket) do
      AurigaWeb.Endpoint.subscribe(topic)
      AurigaWeb.Presence.track(self(), topic, current_user.email, %{})
    end

    {:ok,
     assign(socket,
       room_id: room_id,
       topic: topic,
       room: room,
       message: "",
       current_user: current_user,
       user_list: [],
       messages: messages
     )}
  end

  @impl true
  def handle_event("submit_message", %{"chat" => %{"message" => message}}, socket) do
    content_html = AlchemistMarkdown.to_html(message)

    Repo.insert!(%Message{
      type: "user",
      room: socket.assigns.room,
      user: socket.assigns.current_user,
      content_md: message,
      content_html: content_html
    })

    message = %{
      content: content_html,
      email: socket.assigns.current_user.email,
      inserted_at: Timex.now()
    }

    AurigaWeb.Endpoint.broadcast(socket.assigns.topic, "new-message", message)
    {:noreply, assign(socket, message: "")}
  end

  def handle_event("form_update", %{"chat" => %{"message" => message}}, socket) do
    {:noreply, assign(socket, message: message)}
  end

  @impl true
  def handle_info(%{event: "new-message", payload: message}, socket) do
    {:noreply, assign(socket, messages: Enum.take(socket.assigns.messages ++ [message], -10))}
  end

  def handle_info(%{event: "presence_diff", payload: %{joins: joins, leaves: leaves}}, socket) do
    join_messages =
      joins
      |> Map.keys()
      |> Enum.map(fn email ->
        %{type: :system, content: "<p>#{email} joined</p>", inserted_at: Timex.now()}
      end)

    _join_inserts =
      joins
      |> Map.keys()
      |> Enum.map(fn email ->
        Repo.insert!(%Message{
          type: "system",
          room: socket.assigns.room,
          content_md: "#{email} joined",
          content_html: "<p>#{email} joined</p>"
        })
      end)

    leave_messages =
      leaves
      |> Map.keys()
      |> Enum.map(fn email ->
        %{type: :system, content: "<p>#{email} left</p>", inserted_at: Timex.now()}
      end)

    _leave_inserts =
      leaves
      |> Map.keys()
      |> Enum.map(fn email ->
        Repo.insert!(%Message{
          type: "system",
          room: socket.assigns.room,
          content_md: "#{email} left",
          content_html: "<p>#{email} left</p>"
        })
      end)

    user_list = AurigaWeb.Presence.list(socket.assigns.topic) |> Map.keys()

    {:noreply,
     assign(socket,
       messages: Enum.take(socket.assigns.messages ++ join_messages ++ leave_messages, -10),
       user_list: user_list
     )}
  end

  def display_message(%{type: :system, content: content, inserted_at: inserted_at}) do
    ~E"""
    <div class="message system-message"><i><%= Timex.format!(inserted_at, "{YYYY}-{0M}-{0D} {h24}:{m}") %></i> <%= raw content %></div>
    """
  end

  def display_message(%{email: email, content: content, inserted_at: inserted_at}) do
    ~E"""
    <div class="message user-message"><i><%= Timex.format!(inserted_at, "{h24}:{m}") %></i> <b><%= email %>:</b> <%= raw content %></div>
    """
  end
end
