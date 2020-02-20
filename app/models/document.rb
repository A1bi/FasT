class Document < ApplicationRecord
  has_attached_file :file

  validates_attachment :file, presence: true,
                              content_type: {
                                content_type: %w[image/jpg
                                                 image/jpeg
                                                 image/png
                                                 application/pdf
                                                 application/x-pdf
                                                 audio/mpeg
                                                 audio/mp3]
                              }

  enum members_group: Members::Member.groups, integer_column: true
end
