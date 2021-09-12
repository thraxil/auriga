defmodule AurigaWeb.RoomLive do
  use AurigaWeb, :live_view
  require Logger

  alias Auriga.Accounts
  alias Auriga.Accounts.User

  defp find_current_user(session) do
    with user_token when not is_nil(user_token) <- session["user_token"],
         %User{} = user <- Accounts.get_user_by_session_token(user_token),
         do: user
  end
  
  @impl true
  def mount(%{"id" => room_id}, session, socket) do
    topic = "room:" <> room_id
    current_user = find_current_user(session)

    if connected?(socket) do
      AurigaWeb.Endpoint.subscribe(topic)
      AurigaWeb.Presence.track(self(), topic, current_user.email, %{})
    end
    {:ok,
     assign(socket, room_id: room_id,
       topic: topic,
       message: "",
       current_user: current_user,
       user_list: [],
       messages: [])}
  end

  @impl true
  def handle_event("submit_message", %{"chat" => %{"message" => message}}, socket) do
    message = %{uuid: UUID.uuid4(), content: message, email: socket.assigns.current_user.email}
    AurigaWeb.Endpoint.broadcast(socket.assigns.topic, "new-message", message)
    {:noreply, assign(socket, message: "")}
  end

  def handle_event("form_update", %{"chat" => %{"message" => message}}, socket) do
    {:noreply, assign(socket, message: message)}
  end

  @impl true
  def handle_info(%{event: "new-message", payload: message}, socket) do
    {:noreply, assign(socket, messages: socket.assigns.messages ++ [message])}
  end

  def handle_info(%{event: "presence_diff", payload: %{joins: joins, leaves: leaves}}, socket) do
    join_messages = joins
    |> Map.keys()
    |> Enum.map(fn email -> %{type: :system, uuid: UUID.uuid4(), content: "#{email} joined"} end)

    leave_messages = leaves
    |> Map.keys()
    |> Enum.map(fn email -> %{type: :system, uuid: UUID.uuid4(), content: "#{email} left"} end)

    user_list = AurigaWeb.Presence.list(socket.assigns.topic) |> Map.keys()
    {:noreply, assign(socket, messages: socket.assigns.messages ++ join_messages ++ leave_messages,
      user_list: user_list)}
  end

  def display_message(%{type: :system, uuid: uuid, content: content}) do
    ~E"""
    <p class="system-message"><%= content %><p>
    """
  end

  def display_message(%{uuid: uuid, email: email, content: content}) do
    ~E"""
    <p><b><%= email %>:</b> <%= content %></p>
    """
  end
end
