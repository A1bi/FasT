# frozen_string_literal: true

class AddStateToNewsletters < ActiveRecord::Migration[6.0]
  def change
    add_column :newsletter_newsletters, :status, :integer, default: 0
    rename_column :newsletter_newsletters, :sent, :sent_at

    reversible do |dir|
      dir.up do
        # set sent status which is integer value 2
        update 'UPDATE newsletter_newsletters SET status = 2 WHERE sent_at IS NOT NULL'
      end
    end
  end
end
