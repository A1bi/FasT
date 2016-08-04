module Passbook
  module Models
    class Device < ActiveRecord::Base
      has_many :registrations, dependent: :destroy
      has_many :passes, through: :registrations

      validates_presence_of :device_id, :push_token
    end
  end
end
