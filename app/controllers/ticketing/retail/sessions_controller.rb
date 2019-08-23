module Ticketing::Retail
  class SessionsController < Ticketing::BaseController
    ignore_restrictions
    skip_before_action :reset_goto

    def new
      @stores = Ticketing::Retail::Store.order(:name)
    end

    def create
      self.selected_retail_store_id = params[:store_id]

      store = Ticketing::Retail::Store.find_by(id: params[:store_id])
      if store&.authenticate(params[:password])
        self.current_retail_store = store
        redirect_to new_ticketing_retail_order_path
      else
        redirect_to ticketing_retail_login_path, alert: t("ticketing.retail.sessions.auth_error")
      end
    end

    def destroy
      self.current_retail_store = nil
      redirect_to root_path, notice: t("ticketing.retail.sessions.logout")
    end

    private

    def selected_retail_store_id
      cookies[selected_retail_store_id_cookie_name]
    end
    helper_method :selected_retail_store_id

    def selected_retail_store_id=(id)
      cookies.permanent[selected_retail_store_id_cookie_name] = id
    end

    def selected_retail_store_id_cookie_name
      "_#{Rails.application.class.parent_name}_selected_retail_store_id"
    end
  end
end
