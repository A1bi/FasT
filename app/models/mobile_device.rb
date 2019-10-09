class MobileDevice < BaseModel
  validates :udid, uniqueness: true
end
