# frozen_string_literal: true

class CreateNewsletterImages < ActiveRecord::Migration[6.0]
  def change
    create_table :newsletter_images do |t|
      t.attachment :image
      t.belongs_to :newsletter, null: false, index: true
      t.timestamps
    end
  end
end
