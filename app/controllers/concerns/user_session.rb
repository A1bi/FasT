# frozen_string_literal: true

module UserSession
  extend ActiveSupport::Concern

  included do
    skip_before_action :reset_goto
  end

  private

  def log_in_user(user)
    self.current_user = user
    user.logged_in
    user.save
  end

  def log_out_user
    self.current_user = nil
  end

  def goto_path
    return session[:goto_after_login] if session[:goto_after_login].present?
    return new_privileged_ticketing_order_path if current_user.retail?
    return members_root_path if current_user.member?

    root_path
  end
end
