class MemberMailer < ActionMailer::Base
  default from: I18n.t("action_mailer.defaults.from")
	
	def activation(member)
		@member = member
		mail_to_member
	end
  alias_method :reset_password, :activation
  
  private
  
  def mail_to_member
    mail to: (Rails.env.development?) ? "albo@a0s.de" : @member.email if @member.email.present?
  end
end
