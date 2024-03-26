# frozen_string_literal: true

module Members
  class MemberMailer < ApplicationMailer
    before_action { @member = params[:member] }

    default to: -> { @member.email }

    def welcome
      mail to: member_or_family_member_email
    end

    def activation
      mail
    end

    def reset_password
      mail
    end

    private

    def member_or_family_member_email
      return @member.email if @member.email.present? || !@member.in_family?

      @member.family.members.where.not(email: nil).pick(:email)
    end
  end
end
