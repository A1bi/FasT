module Ticketing::Retail
  class SessionsController < Ticketing::BaseController
    ignore_restrictions
    skip_filter :reset_goto

    def new
      @stores = Ticketing::Retail::Store.order(:name)
    end

    def create
      store = Ticketing::Retail::Store.find(params[:store_id])
      cookies.permanent[selected_retail_store_id_cookie_name] = params[:store_id]
      if store && store.authenticate(params[:password])
        self.retail_store_id_cookie = store.id
        redirect_to new_ticketing_retail_order_path
      else
        redirect_to ticketing_retail_login_path, alert: t("ticketing.retail.sessions.auth_error")
      end
    end

    def destroy
      delete_retail_store_id_cookie
      redirect_to root_path, notice: t("ticketing.retail.sessions.logout")
    end

    private

    def selected_retail_store_id_cookie_name
      "_#{Rails.application.class.parent_name}_selected_retail_store_id"
    end
    helper_method :selected_retail_store_id_cookie_name
  end
end
