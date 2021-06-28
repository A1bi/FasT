# frozen_string_literal: true

module Ticketing
  module SeatingSvg
    class Modifier < Base
      def add_seat_numbers
        num_seats = block_elements.inject(0) do |i, block|
          i + block.css('> g:not(.shield)').inject(0) do |j, seat|
            next j unless (text = seat.css('text').first)

            seat.add_class('seat')
            seat['data-number'] = text.content = j + 1
          end
        end

        save_svg

        num_seats
      end

      def add_row_numbers(block_index:, seats_per_row:, last_row:)
        block = block_elements[block_index]
        first_seat_index = nil
        previous_row = 0

        block.css('g').each_with_index do |seat, i|
          next if seat['data-row'].present?

          # is this the first seat without a row already set ?
          if first_seat_index.nil?
            first_seat_index = i
            # use its row as base row for the following rows
            previous_row = seat.previous_element['data-row'].to_i if seat.previous_element.present?
          end

          row = previous_row + (i - first_seat_index) / seats_per_row + 1
          break if last_row > -1 && row > last_row

          seat['data-row'] = row
          seat.css('text').first.content = row
        end

        save_svg
      end

      def strip_row_numbers
        remove_all_attributes('data-row')

        save_svg
      end

      def strip_ids
        remove_all_attributes('data-id')

        save_svg
      end

      private

      def remove_all_attributes(attr_name)
        svg.xpath("//*[@#{attr_name}]").remove_attr(attr_name)
      end
    end
  end
end
