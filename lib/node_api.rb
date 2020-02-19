class NodeApi
  def self.make_request(name, data)
    socket = Net::BufferedIO.new(UNIXSocket.new('/tmp/FasT-node.sock'))

    path = '/' + name

    request = Net::HTTP::Post.new(path)
    request.body = data.to_json
    request.content_type = 'application/json'

    request.exec(socket, '1.1', path)

    begin
      response = Net::HTTPResponse.read_new(socket)
    end while response.kind_of?(Net::HTTPContinue)
    response.reading_body(socket, request.response_body_permitted?) { }

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
    if !body[:ok]
      nil
    else
      body[:seats]
    end
  end

  def self.update_seats(seats)
    seating_request('updateSeats', seats: seats)
  end

  def self.update_seats_from_records(records)
    seats = {}
    records.each do |record|
      if record.respond_to?(:date_id) && record.respond_to?(:seat) && record.seat.is_a?(Ticketing::Seat)
        seats.deep_merge!({ record.date_id => Hash[[record.seat.node_hash(record.date_id)]] })
      end
    end
    update_seats(seats) if seats.any?
  end
end
