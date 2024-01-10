# frozen_string_literal: true

module Admin
  class WasserwerkController < ApplicationController
    before_action :authorize

    def index
      respond_to do |format|
        format.html
        format.json do
          render json: Wasserwerk.state
        end
      end
    end

    def update
      Wasserwerk.furnace_level = params.dig(:furnace, :level)
      head :no_content
    end

    private

    def authorize
      super(%i[admin wasserwerk])
    end
  end
end
