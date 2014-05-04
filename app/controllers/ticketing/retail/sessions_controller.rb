module Ticketing::Retail
  class SessionsController < Ticketing::BaseController
    ignore_restrictions
    skip_filter :reset_goto
    
    def new
      @stores = Ticketing::Retail::Store.order(:name)
    end
  
    def create
      store = Ticketing::Retail::Store.find(params[:store_id])
      if store && store.authenticate(params[:password])
        session[:retail_store_id] = store.id
        self.retail_store_id_cookie = store.id
        redirect_to new_ticketing_retail_order_path
      else
        redirect_to ticketing_retail_login_path, alert: t("ticketing.retail.sessions.auth_error")
      end
    end

    def destroy
      session[:retail_store_id] = nil
      delete_retail_store_id_cookie
      redirect_to root_path, notice: t("ticketing.retail.sessions.logout")
    end
  end
end
