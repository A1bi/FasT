# frozen_string_literal: true

class NodeApi
  def self.make_request(name, data)
    socket = Net::BufferedIO.new(UNIXSocket.new('/tmp/FasT-node.sock'))

    path = "/#{name}"

    request = Net::HTTP::Post.new(path)
    request.body = data.to_json
    request.content_type = 'application/json'

    request.exec(socket, '1.1', path)

    response = nil
    loop do
      response = Net::HTTPResponse.read_new(socket)
      break unless response.is_a?(Net::HTTPContinue)
    end
    response.reading_body(socket, request.response_body_permitted?) {} # rubocop:disable Lint/EmptyBlock

    response.body = JSON.parse response.body, symbolize_names: true

    response
  end

  def self.seating_request(action, info, socket_id = nil)
    info[:action] = action
    info[:socketId] = socket_id if socket_id
    make_request('seating', info)
  end

  def self.get_chosen_seats(socket_id)
    body = seating_request('getChosenSeats', {}, socket_id).body
    return unless body[:ok]

    body[:seats]
  end

  def self.update_seats(seats)
    seating_request('updateSeats', seats: seats)
  end

  def self.update_seats_from_records(records)
    updated_seats = records.each_with_object({}) do |record, seats|
      next unless record.respond_to?(:date_id) && record.respond_to?(:seat) &&
                  record.seat.is_a?(Ticketing::Seat)

      seats.deep_merge!(
        record.date_id => [record.seat.node_hash(record.date_id)].to_h
      )
    end
    update_seats(updated_seats) if updated_seats.any?
  end
end
