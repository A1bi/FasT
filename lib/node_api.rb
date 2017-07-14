require "net/http"
require "uri"

class NodeApi
  def self.make_request(name, data)
    socket = Net::BufferedIO.new(UNIXSocket.new("/tmp/FasT-node-api.sock"))

    path = "/" + name

    request = Net::HTTP::Post.new(path)
    request.body = data.to_json
    request.content_type = 'application/json'

    request.exec(socket, "1.1", path)

    begin
      response = Net::HTTPResponse.read_new(socket)
    end while response.kind_of?(Net::HTTPContinue)
    response.reading_body(socket, request.response_body_permitted?) { }

    response.body = JSON.parse response.body, symbolize_names: true

    response
  end

  def self.push(action, recipients, recipientIds = nil, info = nil)
    recipientIds.map! { |id| id.to_s }
    data = {
      action: action,
      recipients: recipients,
      recipientIds: recipientIds,
      info: info
    }
    make_request("push", data)
  end

  def self.push_to_app(app, notification, tokens)
    return if tokens.empty?
    data = {
      app: app,
      notification: notification,
      tokens: tokens
    }
    make_request("pushToApp", data)
  end

  def self.seating_request(action, info, client_id = nil)
    info[:action] = action
    info[:clientId] = client_id if client_id
    make_request("seating", info)
  end

  def self.get_chosen_seats(clientId)
    body = seating_request("getChosenSeats", {}, clientId).body
    if !body[:ok]
      nil
    else
      body[:seats]
    end
  end

  def self.update_seats(seats)
    seating_request("updateSeats", { seats: seats })
  end

  def self.update_seats_from_records(records)
    seats = {}
    records.each do |record|
      if record.respond_to?(:date_id) && record.respond_to?(:seat) && record.seat.is_a?(Ticketing::Seat)
        seats.deep_merge!({ record.date_id => Hash[[record.seat.node_hash(record.date_id)]] })
      end
    end
    NodeApi.update_seats(seats) if seats.any?
  end
end
