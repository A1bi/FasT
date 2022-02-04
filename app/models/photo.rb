# frozen_string_literal: true

class Photo < ApplicationRecord
  has_attached_file :image, styles: { thumb: ['145x145#', :jpg], big: ['600', :jpg] },
                            only_process: %i[thumb big original]

  validates_attachment :image, presence: true, content_type:
                         { content_type: %r{\Aimage/(jpe?g|png|hei[cf]|webp)\z} }

  belongs_to :gallery, touch: true
end
