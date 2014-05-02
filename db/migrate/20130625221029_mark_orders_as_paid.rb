class Ticketing::Web::Order < BaseModel
  self.table_name = :ticketing_web_orders
end

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
