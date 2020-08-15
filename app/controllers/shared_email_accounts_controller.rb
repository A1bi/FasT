# frozen_string_literal: true

class SharedEmailAccountsController < ApplicationController
  include Api::Authenticatable

  skip_before_action :authenticate, only: :token

  def token
    authorize :shared_email_accounts

    return if email_authorizing_for.blank?

    token = SharedEmailAccountToken.create(email: email_authorizing_for)
    redirect_to redirect_url(token.id)
  end

  def credentials
    authorize :shared_email_accounts

    token = SharedEmailAccountToken.find(params[:token])
    return head :not_found if token.expired?

    @credentials = credentials_for_email(token.email)
    token.destroy
  end

  private

  def email_authorizing_for
    if params[:email].present? && params[:email].in?(user_shared_email_accounts)
      return params[:email]
    end

    user_shared_email_accounts.first if user_shared_email_accounts.count == 1
  end

  def user_shared_email_accounts
    current_user.shared_email_accounts_authorized_for || []
  end

  def redirect_url(token)
    uri = URI(Settings.shared_email_accounts[:redirect_url])
    query = Rack::Utils.parse_query(uri.query)
    query[:shared_email_account_token] = token
    uri.query = query.to_query
    uri.to_s
  end

  def credentials_for_email(email)
    Rails.application.credentials
         .shared_email_accounts[:credentials].find { |c| c[:email] == email }
  end

  def auth_token
    super || Rails.application.credentials.shared_email_accounts[:api_token]
  end
end
