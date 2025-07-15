# frozen_string_literal: true

class BackstageTvController < ApplicationController
  layout 'minimal'

  skip_authorization

  def index
    @date = Ticketing::EventDate.where(date: 3.hours.ago..).order(date: :asc).first
  end
end
