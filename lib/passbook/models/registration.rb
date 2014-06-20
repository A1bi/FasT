module Passbook
  module Models
    class Registration < ActiveRecord::Base
      belongs_to :device
      belongs_to :pass

      validates_presence_of :device, :pass
    end
  end
end