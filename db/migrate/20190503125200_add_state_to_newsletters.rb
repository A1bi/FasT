class AddStateToNewsletters < ActiveRecord::Migration[5.2]
  def change
    add_column :newsletter_newsletters, :status, :integer, default: 0
    rename_column :newsletter_newsletters, :sent, :sent_at

    reversible do |dir|
      dir.up do
        Newsletter::Newsletter.where.not(sent_at: nil).update_all(status: Newsletter::Newsletter.statuses[:sent]) # rubocop:disable Rails/SkipsModelValidations
      end
    end
  end
end
