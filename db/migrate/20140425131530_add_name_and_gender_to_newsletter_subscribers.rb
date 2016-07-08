class AddNameAndGenderToNewsletterSubscribers < ActiveRecord::Migration
  def change
    add_column :newsletter_subscribers, :gender, :integer
    add_column :newsletter_subscribers, :last_name, :string
  end
end
