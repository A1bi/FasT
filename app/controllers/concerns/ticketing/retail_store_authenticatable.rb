module Ticketing
  module RetailStoreAuthenticatable
    extend ActiveSupport::Concern

    included do
      helper_method :current_retail_store, :retail_store_signed_in?
    end

    protected

    def current_retail_store
      @current_retail_store ||= authenticate_retail_store
    end

    def current_retail_store=(store)
      @current_retail_store = store
      self.current_retail_store_id = store&.id
    end

    def retail_store_signed_in?
      current_retail_store.present?
    end

    private

    def authenticate_retail_store
      return if current_retail_store_id.nil?

      store = Ticketing::Retail::Store.find_by(id: current_retail_store_id)
      self.current_retail_store_id = nil if store.nil?
      store
    end

    def current_retail_store_id
      cookies.signed[retail_store_id_cookie_name]
    end

    def current_retail_store_id=(value)
      cookies.permanent.signed[retail_store_id_cookie_name] = value
    end

    def retail_store_id_cookie_name
      "_#{Rails.application.class.module_parent_name}_retail_store_id"
    end
  end
end
