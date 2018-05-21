class CreateNewsletterSubscriberLists < ActiveRecord::Migration[5.2]
  def change
    add_belongs_to :newsletter_subscribers, :subscriber_list, null: false, default: 1
    add_column :newsletter_subscribers, :consented_at, :datetime

    add_belongs_to :newsletter_newsletters, :subscriber_list, null: false, default: 1

    create_table :newsletter_subscriber_lists do |t|
      t.string :name, null: false
      t.timestamps
    end

    Newsletter::SubscriberList.create(name: 'Kunden')
  end
end
