module Admin
  class AdminController < ApplicationController
    private

    def policy_scope(scope)
      super([:admin, scope])
    end

    def authorize(record, query = nil)
      super([:admin, record], query).last
    end
  end
end
