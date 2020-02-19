module Newsletter
  class SubscriberList < BaseModel
    has_many :subscribers, -> { confirmed }, dependent: :destroy
    has_and_belongs_to_many :newsletters

    validates :name, presence: true
  end
end
