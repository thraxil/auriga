defmodule AurigaWeb.PageLive do
  use AurigaWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: "", results: %{})}
  end

  @impl true
  def handle_event("random-room", _data, socket) do
    random_slug = "/chat/" <> MnemonicSlugs.generate_slug(4)
    Logger.info(random_slug)
    {:noreply, push_redirect(socket, to: random_slug)}
  end
end
