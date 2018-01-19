class Document < BaseModel
  has_attached_file :file

  validates_attachment :file, presence: true, content_type: { content_type: /\A(image\/(jpe?g|png)|application\/(x-)?pdf)\z/ }

  enum members_group: Members::Member.groups
end
