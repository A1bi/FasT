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
  
  def self.push_to_retail_checkout(action, retailId, info = nil)
    push(action, ["retailCheckout"], [retailId], info)
  end
end