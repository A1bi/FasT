class OrderMailer < ActionMailer::Base
  default from: I18n.t("action_mailer.defaults.from")
	
	def confirmation(order)
		@order = order
		
		mail to: (Rails.env.development?) ? "albo@a0s.de" : order.email
	end
end
