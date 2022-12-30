defmodule HtmlToPdfWeb.Reports.CoreComponents do
  use Phoenix.Component

  attr :content, :string, required: true
  attr :rest, :global, default: %{width: "1920", height: "1080"}

  def embed_pdf(assigns) do
    ~H"""
    <div class="flex w-full">
      <embed src={"data:application/pdf;base64,#{@content}"} type="application/pdf" {@rest}>
        <noembed>
          <p>
            Your browser does not support PDF files.
          </p>
        </noembed>
      </embed>
    </div>
    """
  end

  attr :filename, :string, required: true

  def report_stylesheet(assigns) do
    ~H"""
    <style type="text/css">
      <%= load_asset!(@filename) %>
    </style>
    """
  end

  attr :filename, :string, required: true
  attr :rest, :global

  def report_image(assigns) do
    ~H"""
    <img src={"data:image/png;base64,#{load_image!(@filename)}"} {@rest} />
    """
  end

  attr :filename, :string, required: true, doc: "Font file path", examples: ["fonts/fontfile.xxx"]
  attr :family, :string, required: true, doc: "Font family"
  attr :weight, :string, required: true, doc: "Font weight"
  attr :style, :string, default: "normal", doc: "Font style"

  attr :mimetype, :string,
    required: true,
    doc: "Font mimetype for data url",
    examples: ["font/ttf"]

  def report_font(assigns) do
    ~H"""
    <style>
      @font-face {
        font-family: <%= @family %>;
        font-weight: <%= @weight %>;
        font-style: <%= @style %>;
        src: url(data:<%= @mimetype %>;base64,<%= load_font!(@filename) %>);
      }
    </style>
    """
  end

  defp load_asset!(filename) do
    base_path()
    |> Path.join("assets")
    |> do_load!(filename)
  end

  defp load_image!(filename) do
    base_path()
    |> Path.join("images")
    |> do_load!(filename)
  end

  defp load_font!(filename) do
    base_path()
    |> Path.join("fonts")
    |> do_load!(filename)
  end

  defp load_asset_by_extension(content, ".css") do
    content
  end

  defp load_asset_by_extension(content, _extension) do
    Base.encode64(content)
  end

  defp do_load!(base_path, filename) do
    base_path
    |> Path.join(filename)
    |> File.read!()
    |> load_asset_by_extension(Path.extname(filename))
  end

  defp base_path do
    Application.app_dir(:html_to_pdf, "priv/static/")
  end
end
