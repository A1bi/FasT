# frozen_string_literal: true

module Members
  class MemberMailer < ApplicationMailer
    before_action { @member = params[:member] }

    default to: -> { recipient_email }

    def welcome
      mail
    end

    def activation
      mail
    end

    def reset_password
      mail
    end

    private

    def recipient_email
      return @member.email if @member.email.present?
      return unless @member.in_family?

      @member.family.members.where.not(id: @member).first&.email
    end
  end
end
