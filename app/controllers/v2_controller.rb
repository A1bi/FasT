# frozen_string_literal: true

class V2Controller < ApplicationController
  helper :info

  skip_authorization

  def kitchen_sink; end

  def event; end
end
