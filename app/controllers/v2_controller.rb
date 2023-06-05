# frozen_string_literal: true

class V2Controller < ApplicationController
  helper :info

  skip_authorization

  def index; end

  def kitchen_sink; end

  def event; end

  def impressum; end

  def agb; end
end
