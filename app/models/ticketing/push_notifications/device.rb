class Ticketing::PushNotifications::Device < BaseModel
  serialize :settings

  validates_presence_of :token, :app
  validates_uniqueness_of :token, scope: :app

  def push(note)
    NodeApi.push_to_app(app, note, [token])
  end

  def self.push(app, note)
    NodeApi.push_to_app(app, note, where(app: app).map { |device| device.token })
  end
end
