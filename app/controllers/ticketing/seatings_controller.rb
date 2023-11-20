# frozen_string_literal: true

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
          send_data printable(@seating).render, type: 'application/pdf',
                                                disposition: 'inline'
        end
        format.svg { redirect_to @seating.plan.url }
      end
    end

    private

    def find_seatings
      @seatings = Seating.order(:name)
    end

    def printable(seating)
      pdf_config = {
        page_size: 'A4',
        page_layout: :landscape,
        margin: 0
      }

      Prawn::Document.new(pdf_config) do
        plan = Nokogiri::XML(File.read(seating.stripped_plan_path))
        plan.css('.shield').remove
        plan.root << '<style>.seat text { font-weight: bold; }</style>'
        svg plan.to_xml
      end
    end
  end
end
