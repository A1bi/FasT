module Passbook
  module Models
    def self.table_name_prefix
      'passbook_'
    end
  end
  
  def self.options
    @options ||= {}
  end
end

require 'passbook/has_passbook_pass'
require 'passbook/pass'
require 'passbook/routing'

ActionDispatch::Routing::Mapper.send :include, Passbook::Routing