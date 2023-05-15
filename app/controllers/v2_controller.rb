# frozen_string_literal: true

class V2Controller < ApplicationController
  layout 'v2'

  skip_authorization

  def index; end
end
