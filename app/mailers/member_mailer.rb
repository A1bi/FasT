# frozen_string_literal: true

class MemberMailer < ApplicationMailer
  before_action { @member = params[:member] }

  default to: -> { @member.email }

  def activation
    mail
  end

  def reset_password
    mail
  end
end
