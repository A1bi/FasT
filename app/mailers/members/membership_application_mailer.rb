# frozen_string_literal: true

module Members
  class MembershipApplicationMailer < ApplicationMailer
    before_action { @application = params[:application] }

    default to: -> { @application.email }

    def submitted
      mail
    end

    def admin_notification
      mail to: Settings.members.membership_application_admin_notification_email
    end
  end
end
