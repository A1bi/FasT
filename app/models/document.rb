class Document < BaseModel
  has_attached_file :file

  validates_attachment :file, presence: true, content_type: {
    content_type: %r{\A(image\/(jpe?g|png)|application\/(x-)?pdf|audio\/(mpeg|mp3))\z}
  }

  enum members_group: Members::Member.groups
end
