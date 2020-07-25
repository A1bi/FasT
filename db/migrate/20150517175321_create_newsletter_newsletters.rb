# frozen_string_literal: true

class CreateNewsletterNewsletters < ActiveRecord::Migration[6.0]
  def change
    create_table :newsletter_newsletters do |t|
      t.string :subject
      t.text :body_html
      t.text :body_text
      t.datetime :sent

      t.timestamps null: false
    end
  end
end
