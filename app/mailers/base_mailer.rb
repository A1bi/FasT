class BaseMailer < ActionMailer::Base
  default I18n.t("action_mailer.defaults")
  
  def mail(opts)
    opts[:to] = "albo@a0s.de" if Rails.env.development?
    super
  end
end
