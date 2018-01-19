module Members
  class DocumentsController < BaseController
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
