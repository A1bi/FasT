# frozen_string_literal: true

module Api
  class MembersController < ApiController
    SEARCHABLE_COLUMNS = %w[first_name last_name email].freeze

    before_action :authenticate

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

    def authenticate
      token = Rails.application.credentials.members_api_token
      header_token = request.headers['X-Authorization']
      head :unauthorized if !token || token != header_token
    end

    def cache?
      (params.keys & SEARCHABLE_COLUMNS).empty?
    end
    helper_method :cache?
  end
end
