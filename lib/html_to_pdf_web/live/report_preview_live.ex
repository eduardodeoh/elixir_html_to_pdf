defmodule HtmlToPdfWeb.ReportPreviewLive do
  use HtmlToPdfWeb, :live_view

  alias HtmlToPdfWeb.Reports.InvoiceHTML
  alias HtmlToPdf.ReportPDF
  alias HtmlToPdfWeb.Reports

  def mount(_params, _session, socket) do
    reports = [
      %{description: "Invoice", module: InvoiceHTML}
    ]

    socket = assign(socket, reports: reports, show_report_preview: false)

    {:ok, socket, layout: false}
  end

  def render(assigns) do
    ~H"""
    <div class="flex">
      <aside class="w-100 h-screen bg-slate-700 p-10">
        <h1 class="text-white text-xl text-center">Preview Reports</h1>
        <ul class="w-64 mt-3 text-sm font-medium text-gray-900 bg-white rounded-lg">
          <li :for={report <- @reports} class="py-2 px-4 w-full rounded-t-lg">
            <%= report.description %>
            <.button phx-click="preview" phx-value-report={report.description} class="ml-4">
              Preview
            </.button>
          </li>
        </ul>
      </aside>
      <main class="flex-1 max-h-full h-screen">
        <Reports.CoreComponents.embed_pdf :if={@show_report_preview} content={@pdf_base64} />
      </main>
    </div>
    """
  end

  def handle_event("preview", %{"report" => report}, socket) do
    report_config =
      socket.assigns
      |> Map.get(:reports, [])
      |> Enum.find(&(&1.description == report))

    updated_socket =
      case socket.assigns.show_report_preview && report_config.description == report do
        true ->
          assign(socket, pdf_base64: nil, show_report_preview: false)

        false ->
          data = report_config.module.preview_data()
          pdf_metadata = report_config.module.metadata_for_pdf()

          {:ok, pdf_base64} =
            data
            |> InvoiceHTML.render()
            |> ReportPDF.generate_pdf_base64(pdf_metadata)

          assign(socket, pdf_base64: pdf_base64, show_report_preview: true)
      end

    {:noreply, updated_socket}
  end
end
