class Ticketing::PushNotifications::Device < BaseModel
  serialize :settings

  validates_presence_of :token, :app
  validates_uniqueness_of :token, scope: :app

  def push(body: nil, title: nil, badge: nil, sound: nil)
    sound = nil if settings[:sound_enabled].blank?
    Ticketing::PushNotificationsJob.perform_later(self, body: body, title: title, badge: badge, sound: sound)
  end

  def topic
    Settings.apns.topics[app]
  end
end
