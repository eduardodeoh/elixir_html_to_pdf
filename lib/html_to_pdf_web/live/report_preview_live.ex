defmodule HtmlToPdfWeb.ReportPreviewLive do
  use HtmlToPdfWeb, :live_view

  alias HtmlToPdf.ReportPDF
  alias HtmlToPdfWeb.Reports

  def mount(_params, _session, socket) do
    reports = [
      %{name: "invoice", description: "Invoice", module: Reports.InvoiceHTML},
      %{name: "fake", description: "Fake Report", module: Reports.InvoiceHTML}
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
          <li :for={report <- @reports} class="py-2 px-4 w-full rounded-t-lg text-center">
            <.link patch={~p"/report_preview?name=#{report.name}"}>
              Preview <%= report.description %>
            </.link>
          </li>
        </ul>
      </aside>
      <main class="flex-1 max-h-full h-screen">
        <%= if @show_report_preview do %>
          <Reports.CoreComponents.embed_pdf content={@pdf_base64} />
        <% else %>
          <h1 class="mt-10 text-xl text-center">Choose some report on menu to preview</h1>
        <% end %>
      </main>
    </div>
    """
  end

  def handle_params(params, _uri, socket) do
    socket =
      case params["name"] do
        nil ->
          socket

        value ->
          report_module =
            socket.assigns
            |> Map.get(:reports, [])
            |> Enum.find(&(&1.name == value))
            |> Map.fetch!(:module)

          {:ok, pdf_base64} = generate_pdf_base64(report_module)

          assign(socket, pdf_base64: pdf_base64, show_report_preview: true)
      end

    {:noreply, socket}
  end

  defp generate_pdf_base64(report_module) do
    data = report_module.preview_data()
    pdf_metadata = report_module.metadata_for_pdf()

    data
    |> report_module.render()
    |> ReportPDF.generate_pdf_base64(pdf_metadata)
  end
end
