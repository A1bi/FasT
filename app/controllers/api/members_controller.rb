# frozen_string_literal: true

module Api
  class MembersController < ApiController
    include Authenticatable

    SEARCHABLE_COLUMNS = %w[first_name last_name email].freeze

    def index
      table = Members::Member.arel_table
      matches = nil

      SEARCHABLE_COLUMNS.each do |column|
        value = params[column]
        next if value.blank?

        value = value['0'] if value.is_a?(ActionController::Parameters)
        value = ActiveSupport::Inflector.transliterate(value)
        term = table[column].matches("%#{value}%")
        matches = matches ? matches.or(term) : term
      end

      @members = Members::Member.where(matches).alphabetically
    end

    def show
      @member = Members::Member.find(params[:id])
    end

    private

    def auth_token
      super || Rails.application.credentials.members_api_token
    end

    def cache?
      !params.keys.intersect?(SEARCHABLE_COLUMNS)
    end
    helper_method :cache?
  end
end
