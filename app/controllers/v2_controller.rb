# frozen_string_literal: true

class V2Controller < ApplicationController
  skip_authorization

  def kitchen_sink; end
end
