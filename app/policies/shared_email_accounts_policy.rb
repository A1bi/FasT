# frozen_string_literal: true

SharedEmailAccountsPolicy = Struct.new(:user, :shared_email_accounts) do
  def token?
    user.shared_email_accounts_authorized_for&.any?
  end
end
