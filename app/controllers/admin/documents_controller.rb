module Admin
  class DocumentsController < BaseController
    include DocumentManagement

    def index
      @documents = Document.admin.all
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
