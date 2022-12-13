defmodule HtmlToPdf.Repo do
  use Ecto.Repo,
    otp_app: :html_to_pdf,
    adapter: Ecto.Adapters.Postgres
end
