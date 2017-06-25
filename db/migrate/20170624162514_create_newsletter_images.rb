class CreateNewsletterImages < ActiveRecord::Migration[5.1]
  def change
    create_table :newsletter_images do |t|
      t.attachment :image
      t.belongs_to :newsletter, null: false, index: true
      t.timestamps
    end
  end
end
