# frozen_string_literal: true

class MakeEmailsCaseInsensitive < ActiveRecord::Migration[6.0]
  def change
    %i[users newsletter_subscribers].each do |table|
      remove_index table, column: :email, unique: true
      add_index table, 'LOWER(email)',
                unique: true, name: "index_#{table}_on_lower_email"
    end
  end
end
