class MarkOrdersAsPaid < ActiveRecord::Migration
  def up
    Ticketing::Web::Order.where(pay_method: "charge").each do |order|
      order.bunch.paid = true
      order.bunch.save
    end
    
    # generate passbook passes for all tickets
    Ticketing::Ticket.all.each do |bunch|
      bunch.save
    end
  end
end
