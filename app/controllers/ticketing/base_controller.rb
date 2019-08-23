class Ticketing::BaseController < ApplicationController
  include Ticketing::OrderingType

  restrict_access_to_group :admin

  before_action :disable_slides
  before_action :authenticate_retail_store
  before_action :disable_member_controls_for_retail

  helper Ticketing::TicketingHelper

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

  helper_method :current_retail_store, :retail_store_signed_in?

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
    "_#{Rails.application.class.parent_name}_retail_store_id"
  end

  def orders_path(action, params = nil)
    action = action.to_s.sub("ticketing", "ticketing_retail") if retail?
    send(action.to_s + "_path", params)
  end
  helper_method :orders_path

  def disable_member_controls_for_retail
    disable_member_controls if retail? && !user_signed_in?
  end
end
