module Ticketing
  class SeatsController < BaseController
    before_filter :find_all_seats, only: [:index, :edit]

    def index
      respond_to do |format|
        format.html
        format.pdf do
          send_data printable(@seats).render, type: "application/pdf", disposition: "inline"
        end
      end
    end

    def edit
      @blocks = Ticketing::Block.order(:id)
      @new_seats = @blocks.map do |block|
        seat = Ticketing::Seat.new
        seat.block = block
        seat
      end
    end

    def create
      seat = Ticketing::Seat.new(seat_params)
      if seat.save
        render json: {
          ok: true,
          id: seat.id
        }
      else
        render json: {
          ok: false
        }
      end
    end

    def update
      seat_params = params.permit(seats: [:number, :position_x, :position_y]).fetch(:seats, {})
      Ticketing::Seat.update(seat_params.keys, seat_params.values)

      render nothing: true
    end

    def destroy
      Ticketing::Seat.destroy(params[:ids])

      render nothing: true
    end

    private

    def find_all_seats
      seating = Ticketing::Event.current.seating
      seating = Ticketing::Seating.where(number_of_seats: 0).last if !seating.bound_to_seats?
      @seats = seating.seats.order(:number)
    end

    def seat_params
      params.require(:seat).permit(:number, :row, :block_id, :position_x, :position_y)
    end

    def printable(seats)
      pdf_config = {
        page_size: "A4",
        page_layout: :landscape
      }

      colors = {
        red: "ff0000",
        green: "008000",
        yellow: "ffff00",
        blue: "0000ff",
        gray: "808080",
        black: "000000",
        white: "ffffff"
      }

      Prawn::Document.new(pdf_config) do
        cell_size = bounds.width / 150
        seat_size = cell_size * 2.8
        seat_padding = 1

        seats.all.each do |seat|
          bounding_box [seat.position_x * cell_size, bounds.height - seat.position_y * cell_size], width: seat_size, height: seat_size do
            fill_color colors[seat.block.color.to_sym] || "ffffff"
            fill_rounded_rectangle [0, 0], bounds.width, bounds.height, 1

            fill_color "ffffff"
            text_box seat.number.to_s,
              at: [seat_padding, -seat_padding],
              width: bounds.width - seat_padding * 2, height: bounds.height - seat_padding * 2,
              align: :center, valign: :center,
              mode: :fill,
              size: cell_size * 1.9, style: :normal,
              overflow: :shrink_to_fit
          end
        end
      end
    end
  end
end
