class MemberMailer < BaseMailer
  def activation(member)
    @member = member
    mail_to_member
  end
  alias reset_password activation

  private

  def mail_to_member
    mail to: @member.email if @member.email.present?
  end
end
