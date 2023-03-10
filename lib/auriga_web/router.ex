defmodule AurigaWeb.Router do
  use AurigaWeb, :router

  import AurigaWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {AurigaWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AurigaWeb do
    pipe_through :browser
  end

  # Other scopes may use custom stacks.
  # scope "/api", AurigaWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: AurigaWeb.Telemetry
    end
  end

  ## Authentication routes

  scope "/", AurigaWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", AurigaWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email

    live "/", PageLive, :index
    live "/chat/:id", RoomLive, :index

    # presentations
    get "/presentations/", PresentationController, :index
    get "/presentations/new/", PresentationController, :new
    get "/presentations/:id/", PresentationController, :show
    post "/presentations/:id/add_slide/", PresentationController, :add_slide
    post "/presentations/:id/delete_slide/:slide_id", PresentationController, :delete_slide
    post "/presentations/:id/delete/", PresentationController, :delete
    post "/presentations/", PresentationController, :create
    get "/presentations/:id/slide/:slide_id/", PresentationController, :show_slide
    put "/presentations/:id/slide/:slide_id/", PresentationController, :edit_slide

    # live present
    live "/present/:id", PresentLive, :index
  end

  scope "/", AurigaWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :confirm
  end
end
