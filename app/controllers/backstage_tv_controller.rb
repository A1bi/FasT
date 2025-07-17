# frozen_string_literal: true

class BackstageTvController < ApplicationController
  layout 'minimal'

  skip_authorization

  def index
    @date = Ticketing::EventDate.imminent
  end
end
