class MemberMailer < ActionMailer::Base
  default from: I18n.t("action_mailer.defaults.from")
	
	def activation(member)
		@member = member
		
		mail to: (Rails.env.development?) ? "albo@a0s.de" : member.email
	end
end
