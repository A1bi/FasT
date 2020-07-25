# frozen_string_literal: true

class CreateNewsletterSubscribers < ActiveRecord::Migration[6.0]
  def change
    create_table :newsletter_subscribers do |t|
      t.string :email
      t.string :token

      t.timestamps
    end
  end
end
