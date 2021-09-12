defmodule AurigaWeb.RoomLive do
  use AurigaWeb, :live_view
  require Logger

  @impl true
  def mount(%{"id" => room_id}, _session, socket) do
    topic = "room:" <> room_id
    username = MnemonicSlugs.generate_slug(2)
    if connected?(socket) do
      AurigaWeb.Endpoint.subscribe(topic)
      AurigaWeb.Presence.track(self(), topic, username, %{})
    end
    {:ok,
     assign(socket, room_id: room_id,
       topic: topic,
       message: "",
       username: username,
       user_list: [],
       messages: [])}
  end

  @impl true
  def handle_event("submit_message", %{"chat" => %{"message" => message}}, socket) do
    message = %{uuid: UUID.uuid4(), content: message, username: socket.assigns.username}
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
    |> Enum.map(fn username -> %{type: :system, uuid: UUID.uuid4(), content: "#{username} joined"} end)

    leave_messages = leaves
    |> Map.keys()
    |> Enum.map(fn username -> %{type: :system, uuid: UUID.uuid4(), content: "#{username} left"} end)

    user_list = AurigaWeb.Presence.list(socket.assigns.topic) |> Map.keys()
    {:noreply, assign(socket, messages: socket.assigns.messages ++ join_messages ++ leave_messages,
      user_list: user_list)}
  end

  def display_message(%{type: :system, uuid: uuid, content: content}) do
    ~E"""
    <p class="system-message"><%= content %><p>
    """
  end

  def display_message(%{uuid: uuid, username: username, content: content}) do
    ~E"""
    <p><b><%= username %>:</b> <%= content %></p>
    """
  end
end
