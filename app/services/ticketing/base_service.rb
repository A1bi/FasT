module Ticketing
  class BaseService
    attr_accessor :current_user, :params

    def initialize(current_user = nil, params = {})
      @current_user = current_user
      @params = params
    end
  end
end
