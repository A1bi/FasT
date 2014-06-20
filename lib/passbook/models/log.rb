module Passbook
  module Models
    class Log < ActiveRecord::Base
      validates_presence_of :message
    end
  end
end