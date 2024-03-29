defmodule HtmlToPdf.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @chromic_pdf_opts Application.compile_env!(:html_to_pdf, ChromicPDF)

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      HtmlToPdfWeb.Telemetry,
      # Start the Ecto repository
      HtmlToPdf.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: HtmlToPdf.PubSub},
      # Start Finch
      {Finch, name: HtmlToPdf.Finch},
      # Start the Endpoint (http/https)
      HtmlToPdfWeb.Endpoint,
      # Start a worker by calling: HtmlToPdf.Worker.start_link(arg)
      # {HtmlToPdf.Worker, arg}
      {ChromicPDF, chromic_pdf_opts()}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HtmlToPdf.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HtmlToPdfWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp chromic_pdf_opts do
    @chromic_pdf_opts
  end
end
