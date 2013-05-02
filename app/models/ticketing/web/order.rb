module Ticketing
  class Web::Order < ActiveRecord::Base
    include Orderable
  
    attr_accessible :email, :first_name, :gender, :last_name, :phone, :plz
	
    has_one :bank_charge, :as => :chargeable, :validate => true
  
    validates_presence_of :email, :first_name, :last_name, :phone, :plz
    validates_inclusion_of :gender, :in => 0..1
    validates_numericality_of :plz, :only_integer => true, :less_than => 100000, :greater_than => 1000
    validates :email, :email_format => true
    validates_inclusion_of :pay_method, :in => ["charge", "transfer"]
  
  end
end