# frozen_string_literal: true

module Passbook
  class << self
    attr_accessor :destination_path, :wwdr_ca_path
    attr_reader :models

    def configure
      @models = {}
      yield self
    end

    def register_model(model, template:, pass_type_id:, certificate_path:)
      @models[model] = {
        template:,
        pass_type_id:,
        certificate_path:
      }
    end
  end

  module Models
    def self.table_name_prefix
      'passbook_'
    end
  end
end

require 'passbook/has_passbook_pass'
require 'passbook/pass'
require 'passbook/routing'

ActionDispatch::Routing::Mapper.include Passbook::Routing
