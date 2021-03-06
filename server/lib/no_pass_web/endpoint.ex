defmodule NoPassWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :no_pass

  socket("/socket", NoPassWeb.UserSocket)

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug(Plug.Static, at: "/", from: :no_pass, gzip: true)
  # only: ["main.html", "fonts", "images", "favicon.ico", "robots.txt", "bundle.js",
  # ".well-known", "android-chrome-192x192.png", "android-chrome-512x512.png",
  # "apple-touch-icon.png", "favicon-16x16.png", "favicon-32x32.png",
  # "safari-pinned-tab.svg", "service-worker.js", "site.webmanifest"]

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket)
    plug(Phoenix.LiveReloader)
    plug(Phoenix.CodeReloader)
  end

  plug(Plug.RequestId)
  plug(Plug.Logger)

  plug(
    Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug(
    Plug.Session,
    store: :cookie,
    key: "_no_pass_key",
    signing_salt: "9hfAG+LC"
  )

  # TODO: maybe only allow some URLs?
  # https://github.com/mschae/cors_plug
  plug(CORSPlug)

  plug(NoPassWeb.Router)

  @doc """
  Callback invoked for dynamically configuring the endpoint.

  It receives the endpoint configuration and checks if
  configuration should be loaded from the system environment.
  """
  def init(_key, config) do
    if config[:load_from_system_env] do
      port = System.get_env("PORT") || raise "expected the PORT environment variable to be set"
      {:ok, Keyword.put(config, :http, [:inet6, port: port])}
    else
      {:ok, config}
    end
  end
end
