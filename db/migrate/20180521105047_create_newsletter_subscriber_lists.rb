class CreateNewsletterSubscriberLists < ActiveRecord::Migration[5.2]
  def change
    add_belongs_to :newsletter_subscribers, :subscriber_list, null: false, default: 1
    add_column :newsletter_subscribers, :confirmed_at, :datetime

    create_table :newsletter_subscriber_lists do |t|
      t.string :name, null: false
      t.timestamps
    end

    create_table :newsletter_newsletters_subscriber_lists, id: false do |t|
      t.belongs_to :newsletter, index: { name: 'index_newsletter_newsletters_subscriber_lists_on_letter_id' }
      t.belongs_to :subscriber_list, index: { name: 'index_newsletter_newsletters_subscriber_lists_on_list_id' }
    end

    Newsletter::SubscriberList.create(name: 'Kunden')

    Newsletter::Subscriber.all.each do |subscriber|
      subscriber.update(confirmed_at: subscriber.created_at)
    end
  end
end
