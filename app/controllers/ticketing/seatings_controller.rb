module Ticketing
  class SeatingsController < BaseController
    before_action :find_seatings, only: %w[index show]

    def index
      redirect_to authorize(@seatings.first)
    end

    def show
      @seating = authorize @seatings.find(params[:id])

      respond_to do |format|
        format.html
        format.pdf do
          send_data printable(@seating).render, type: 'application/pdf', disposition: 'inline'
        end
        format.svg { redirect_to url_for(@seating.plan) }
      end
    end

    private

    def find_seatings
      @seatings = Seating.where(number_of_seats: 0)
    end

    def printable(seating)
      pdf_config = {
        page_size: 'A4',
        page_layout: :landscape,
        margin: 0
      }

      Prawn::Document.new(pdf_config) do
        plan = Nokogiri::XML(File.read(seating.plan_path(absolute: true)))
        plan.css('.shield').remove
        plan.root << '<style>.seat text { font-weight: bold; }</style>'
        svg plan.to_xml
      end
    end
  end
end
