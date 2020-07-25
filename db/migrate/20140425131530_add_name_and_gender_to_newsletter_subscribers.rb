# frozen_string_literal: true

class AddNameAndGenderToNewsletterSubscribers < ActiveRecord::Migration[6.0]
  def change
    change_table :newsletter_subscribers, bulk: true do |t|
      t.integer :gender
      t.string :last_name
    end
  end
end
