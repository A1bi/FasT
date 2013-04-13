class Ticketing::BankCharge < ActiveRecord::Base
  attr_accessible :bank, :blz, :name, :number
  
  belongs_to :chargeable, :polymorphic => true
end
