module Api
  class MembersController < ApiController
    before_action :authenticate

    def index
      searchable_columns = %w[first_name last_name email]
      cache = (params.keys & searchable_columns).empty?

      render_cached_json_if [:api, :members, :index, Members::Member.all], cache do
        table = Members::Member.arel_table
        matches = nil

        searchable_columns.each do |column|
          value = params[column]
          next if value.blank?

          value = value['0'] if value.is_a?(ActionController::Parameters)
          value = ActiveSupport::Inflector.transliterate(value)
          term = table[column].matches("%#{value}%")
          matches = matches ? matches.or(term) : term
        end

        members = Members::Member.where(matches).alphabetically

        members.map do |member|
          {
            id: member.id,
            email: member.email,
            first_name: member.first_name,
            last_name: member.last_name
          }
        end
      end
    end

    def show
      member = Members::Member.find(params[:id])

      response = [{
        id: member.id,
        email: member.email,
        first_name: member.first_name,
        last_name: member.last_name
      }]

      render json: response
    end

    private

    def authenticate
      token = Rails.application.credentials.members_api_token
      header_token = request.headers['X-Authorization']
      head :unauthorized if !token || token != header_token
    end
  end
end
