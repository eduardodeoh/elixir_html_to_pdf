defmodule HtmlToPdf.ReportPDF do
  def generate_pdf_base64(html_iodata, pdf_metadata \\ %{}) do
    ChromicPDF.print_to_pdfa({:html, html_iodata},
      print_to_pdf: print_to_pdf_options(),
      info: pdf_metadata
    )
  end

  def generate_pdf_file(html_iodata, filename \\ "output.pdf", pdf_metadata \\ %{}) do
    ChromicPDF.print_to_pdfa({:html, html_iodata},
      print_to_pdf: print_to_pdf_options(),
      info: pdf_metadata,
      output: filename
    )
  end

  def generate_pdf_screenshot(html_iodata, format \\ "jpeg", filename \\ "output") do
    ChromicPDF.capture_screenshot(
      {:html, html_iodata},
      capture_screenshot: %{
        format: format,
        quality: 100,
        # clip: => "some-viewport",
        fromSurface: true,
        captureBeyondViewport: true
      },
      output: "#{filename}.#{format}"
    )
  end

  defp print_to_pdf_options do
    %{
      # Chrome Page.printToPDF options
      # https://chromedevtools.github.io/devtools-protocol/tot/Page/#method-printToPDF
      # Paper sizes in inch:
      # https://github.com/bitcrowd/chromic_pdf/blob/v1.4.0/lib/chromic_pdf/template.ex#L67
      # paperWidth: 8.3,
      # paperHeight: 11.7,
      # Required to use @page media from css
      marginTop: 0,
      marginLeft: 0,
      marginRight: 0,
      marginBottom: 0,
      printBackground: true,
      displayHeaderFooter: false,
      landscape: false,
      preferCSSPageSize: true
    }
  end
end
