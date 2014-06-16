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
  
  def self.update_seats(seats)
    seating_request("updateSeats", { seats: seats })
  end
  
  def self.update_seats_from_tickets(tickets)
    seats = {}
    tickets.each do |ticket|
      seats.deep_merge!({ ticket.date_id => Hash[[ticket.seat.node_hash(ticket.date_id)]] })
    end
    NodeApi.update_seats(seats)
  end
end