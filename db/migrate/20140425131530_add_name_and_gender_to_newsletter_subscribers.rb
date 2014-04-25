class AddNameAndGenderToNewsletterSubscribers < ActiveRecord::Migration
  def change
    add_column :newsletter_subscribers, :gender, :integer
    add_column :newsletter_subscribers, :last_name, :string
  end
  
  def migrate(direction)
    super
    if direction == :up
      Newsletter::Subscriber.all.each do |subscriber|
        order = Ticketing::Web::Order.where(email: subscriber.email).first
        next if order.nil?
        subscriber.update_attributes({ last_name: order.last_name, gender: order.gender })
      end
    end
  end
end
