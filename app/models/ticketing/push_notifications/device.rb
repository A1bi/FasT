class Ticketing::PushNotifications::Device < BaseModel
  validates_presence_of :token, :app
  validates_uniqueness_of :token, scope: :app
end
