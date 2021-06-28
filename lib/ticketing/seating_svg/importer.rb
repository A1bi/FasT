# frozen_string_literal: true

module Ticketing
  module SeatingSvg
    class Importer < Base
      def import(name:)
        @name = name

        ActiveRecord::Base.transaction do
          iterate_blocks
          save_seating
        end

        seating
      end

      private

      def seating
        @seating ||= if (id = svg.root['data-id']).blank?
                       record = Ticketing::Seating.create(name: @name)
                       svg.root['data-id'] = record.id
                       record
                     else
                       Ticketing::Seating.find(id)
                     end
      end

      def iterate_blocks
        block_elements.each do |block_element|
          title = block_element.css('> title').first&.content

          if (id = block_element['data-id']).present?
            block = Ticketing::Block.find(id)
            block.update(name: title)
            log_saved_changes(block)

          else
            block = seating.blocks.create(name: title)
            block_element['data-id'] = block.id
            log_created_record(block)
          end

          seats = iterate_seats(block_element, block)
          find_missing_seats(block, seats)
        end
      end

      def iterate_seats(block_element, block)
        block_element.css('.seat').each_with_object([]) do |seat_element, seats|
          number = seat_element['data-number']
          row = seat_element['data-row']

          if (id = seat_element['data-id']).present?
            seat = Ticketing::Seat.find(id)
            seat.update(block: block, row: row, number: number)
            log_saved_changes(seat)

          else
            seat = block.seats.create(row: row, number: number)
            seat_element['data-id'] = seat.id
            log_created_record(seat, block)
          end

          seats << seat
        end
      end

      def find_missing_seats(block, seats)
        return if block.new_record?

        block.seats.where.not(id: seats.map(&:id)).each do |seat|
          Rails.logger.info "Seat '#{seat.number}' in Block '#{block.name}' " \
                      "with id=#{seat.id} is missing from the SVG file " \
                      'and will therefore be removed.'

          raise 'This seat cannot be removed due to existing tickets.' if seat.tickets.any?

          seat.destroy
        end
      end

      def save_seating
        seating.update(plan: StringIO.new(svg.to_xml),
                       plan_file_name: 'seating.svg')
        log_saved_changes(seating)
      end

      def log_created_record(record, association = nil)
        assoc_info = " (#{association.class.name} with id=#{association.id})" if association

        Rails.logger.info "#{record.class.name} with id=#{record.id}" \
                    "#{assoc_info} created."
      end

      def log_saved_changes(record)
        return unless record.saved_changes?

        saved_changes = record.saved_changes.except(:updated_at)
        Rails.logger.info "#{record.class.name} with id=#{record.id} " \
                          "changed: #{saved_changes}"
      end
    end
  end
end
