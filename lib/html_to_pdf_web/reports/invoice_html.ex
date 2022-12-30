defmodule HtmlToPdfWeb.Reports.InvoiceHTML do
  use HtmlToPdfWeb, :html_report

  alias HtmlToPdfWeb.Reports.Layouts

  embed_templates "invoice_html/*"

  def render(assigns) do
    assigns = Map.put(assigns, :layout, {Layouts, "root"})
    Phoenix.Template.render_to_iodata(__MODULE__, "template", "html", assigns)
  end

  # https://hexdocs.pm/chromic_pdf/ChromicPDF.html#t:info_option/0
  def metadata_for_pdf do
    %{
      title: "Invoice",
      author: "Invoice Author",
      subject: "Invoice",
      keywords: "invoice",
      creator: "Report project"
    }
  end

  def preview_data do
    %{
      invoice_source_data: %{
        title: "From",
        name: "Company A",
        street: "Street Brazil",
        city: "São Paulo",
        post_code: "01000-000"
      },
      invoice_target_data: %{
        title: "Billed to",
        name: "Company B",
        street: "Street 1234",
        city: "NY",
        post_code: "CA 5678",
        country: "USA"
      },
      invoice_details_data: %{
        number: "0001",
        issue_date: "12/20/2022"
      },
      invoice_currency: "USD",
      invoice_items: [
        %{
          name: "Service 1",
          value: "530.25"
        },
        %{
          name: "Service 2",
          value: "830.75"
        }
      ],
      invoice_totals: [
        %{
          title: "Subtotal",
          active: true,
          value: "1361.00",
          subtitle: %{
            active: false
          }
        },
        %{
          title: "Discount",
          active: true,
          value: "5.00",
          subtitle: %{
            active: true,
            value: "5",
            type: "flat"
          }
        },
        %{
          title: "Tax",
          active: true,
          value: "135.60",
          subtitle: %{
            active: true,
            value: "10",
            type: "percent"
          }
        },
        %{
          title: "Total",
          active: true,
          value: "1491.60",
          subtitle: %{
            active: false
          }
        }
      ]
    }
  end

  attr :title, :string, required: true, doc: "Title name"
  attr :name, :string, required: true, doc: "Company name"
  attr :street, :string, required: true, doc: "Street name"
  attr :city, :string, required: true, doc: "City name"
  attr :post_code, :string, required: true, doc: "Post code"
  attr :country, :string, default: "Brazil", doc: "Country name"

  def invoice_data(assigns) do
    ~H"""
    <div class="text-sm font-light text-slate-500">
      <p class="text-sm font-normal text-slate-700"><%= @title %></p>
      <p><%= @name %></p>
      <p><%= @street %></p>
      <p><%= @city %></p>
      <p><%= @post_code %></p>
      <p><%= @country %></p>
    </div>
    """
  end

  attr :number, :string, required: true, doc: "Invoice number"
  attr :issue_date, :string, required: true, doc: "Invoice issue date"

  def invoice_details(assigns) do
    ~H"""
    <div class="text-sm font-light text-slate-500">
      <p class="text-sm font-normal text-slate-700">Invoice Number</p>
      <p><%= @number %></p>

      <p class="mt-2 text-sm font-normal text-slate-700">Date of Issue</p>
      <p><%= @issue_date %></p>
    </div>
    """
  end

  slot :inner_block, required: true

  def invoice_notes(assigns) do
    ~H"""
    <div class="border-t pt-9 border-slate-200">
      <div class="text-sm font-light text-slate-700 font-roboto">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  attr :items, :map, required: true
  attr :currency, :string, default: "USD", values: ~w(USD BRL CAD)

  def invoice_table_items(assigns) do
    ~H"""
    <tr :for={item <- @items} class="border-b border-slate-200">
      <td class="py-4 pl-4 pr-3 text-sm sm:pl-6 md:pl-0">
        <div class="font-medium text-slate-700"><%= item.name %></div>
      </td>
      <td class="hidden px-3 py-4 text-sm text-right text-slate-500 sm:table-cell"></td>
      <td class="hidden px-3 py-4 text-sm text-right text-slate-500 sm:table-cell"></td>
      <td class="py-4 pl-3 pr-4 text-sm text-right text-slate-500 sm:pr-6 md:pr-0">
        <%= @currency %> <%= item.value %>
      </td>
    </tr>
    """
  end

  def invoice_table_totals(assigns) do
    ~H"""
    <%= for item <- @items do %>
      <tr :if={item.active}>
        <th
          scope="row"
          colspan="3"
          class="hidden pt-6 pl-6 pr-3 text-sm font-light text-right text-slate-500 sm:table-cell md:pl-0"
        >
          <.render_total_title
            :if={item.active}
            currency={@currency}
            title={item.title}
            subtitle={item.subtitle}
          />
        </th>
        <th scope="row" class="pt-6 pl-4 pr-3 text-sm font-light text-left text-slate-500 sm:hidden">
          <.render_total_title
            :if={item.active}
            currency={@currency}
            title={item.title}
            subtitle={item.subtitle}
          />
        </th>
        <td class="pt-6 pl-3 pr-4 text-sm text-right text-slate-500 sm:pr-6 md:pr-0">
          <%= @currency %> <%= item.value %>
        </td>
      </tr>
    <% end %>
    """
  end

  attr :title, :string, required: true
  attr :subtitle, :map, required: true
  attr :currency, :string, default: "USD", values: ~w(USD BRL CAD)

  def render_total_title(assigns) do
    ~H"""
    <%= @title %>
    <.render_total_subtitle
      :if={@subtitle.active}
      value={@subtitle.value}
      type={@subtitle.type}
      currency={@currency}
    />
    """
  end

  attr :value, :string, required: true
  attr :type, :string, required: true
  attr :currency, :string, default: "USD", values: ~w(USD BRL CAD)

  def render_total_subtitle(assigns) do
    ~H"""
    <%= if @type == "flat" do %>
      (<%= @currency %> <%= @value %>)
    <% else %>
      (<%= @value %>%)
    <% end %>
    """
  end
end
