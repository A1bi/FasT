# frozen_string_literal: true

SharedEmailAccountsPolicy = Struct.new(:user, :shared_email_accounts) do
  def token?
    user&.shared_email_accounts_authorized_for&.any? && user.web_authn_set_up?
  end

  def credentials?
    true
  end
end
