# frozen_string_literal: true

module Members
  class DocumentsController < ApplicationController
    include DocumentManagement

    protected

    def members_group
      :member
    end

    def redirect_path
      members_root_path
    end
  end
end
