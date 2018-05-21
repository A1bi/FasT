module Newsletter
  class SubscriberList < BaseModel
    has_many :subscribers

    validates :name, presence: true
  end
end
