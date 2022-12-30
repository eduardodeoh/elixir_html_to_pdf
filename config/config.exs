# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :html_to_pdf,
  ecto_repos: [HtmlToPdf.Repo]

# Configures the endpoint
config :html_to_pdf, HtmlToPdfWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: HtmlToPdfWeb.ErrorHTML, json: HtmlToPdfWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: HtmlToPdf.PubSub,
  live_view: [signing_salt: "WGwlRIKt"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :html_to_pdf, HtmlToPdf.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.41",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.1.8",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configures ChromicPDF
config :html_to_pdf, ChromicPDF,
  disable_scripts: true,
  on_demand: false,
  offline: true,
  no_sandbox: true,
  discard_stderr: true,
  session_pool: [
    size: 3,
    timeout: 10_000,
    init_timeout: 10_000
  ],
  ghostscript_pool: [size: 10],
  max_session_uses: 1000,
  # Chrome options
  # https://hexdocs.pm/chromic_pdf/ChromicPDF.html#module-chrome-options
  # https://peter.sh/experiments/chromium-command-line-switches/#print-to-pdf-no-header
  # Default chrome args
  # https://github.com/bitcrowd/chromic_pdf/blob/f3aa604e32ecbf18b7f57db4d501e1ecb94c695d/lib/chromic_pdf/pdf/chrome_impl.ex#L47
  chrome_args:
    ~w(
      no-zygote
      window-size=800,600
      disable-webgl
      font-render-hinting=none
    )
    |> Enum.map(&"--#{&1}")
    |> Enum.join(" ")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
