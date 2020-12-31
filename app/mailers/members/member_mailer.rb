# frozen_string_literal: true

module Members
  class MemberMailer < ApplicationMailer
    before_action { @member = params[:member] }

    default to: -> { @member.email }

    def welcome
      mail
    end

    def activation
      mail
    end

    def reset_password
      mail
    end
  end
end
