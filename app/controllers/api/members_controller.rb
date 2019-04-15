module Api
  class MembersController < ApplicationController
    before_action :authenticate

    def index
      members = Members::Member.alphabetically

      response = members.map do |member|
        {
          id: member.id,
          email: member.email,
          first_name: member.first_name,
          last_name: member.last_name
        }
      end

      render json: response
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
