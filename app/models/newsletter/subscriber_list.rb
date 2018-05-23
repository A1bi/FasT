module Newsletter
  class SubscriberList < BaseModel
    has_many :subscribers

    validates :name, presence: true

    def subscribers
      super.confirmed
    end
  end
end
