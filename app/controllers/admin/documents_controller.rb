module Admin
  class DocumentsController < ApplicationController
    include DocumentManagement

    def index
      @documents = authorize Document.admin
    end

    protected

    def members_group
      :admin
    end

    def redirect_path
      admin_documents_path
    end
  end
end
