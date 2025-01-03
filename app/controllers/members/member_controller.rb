# frozen_string_literal: true

module Members
  class MemberController < ApplicationController
    include UserSession

    before_action :set_activation_token_purpose, only: %i[activate finish_activation]
    before_action :set_password_reset_token_purpose, only: %i[reset_password finish_reset_password]
    before_action :find_member_by_token, only: %i[activate finish_activation reset_password finish_reset_password]

    rescue_from ActiveSupport::MessageVerifier::InvalidSignature, with: :handle_invalid_token

    def activate; end

    def finish_activation
      update_password(:activate, :activated)
    end

    def reset_password; end

    def finish_reset_password
      update_password(:reset_password, :password_changed)
    end

    def edit
      authorize current_user, policy_class: MemberPolicy
    end

    def update
      authorize(current_user, policy_class: MemberPolicy)
        .assign_attributes(permitted_attributes(current_user))
      if current_user.save(context: :user_update)
        flash.notice = t('application.saved_changes')
        redirect_to action: :edit
      else
        render action: :edit
      end
    end

    def forgot_password
      authorize Member
    end

    def finish_forgot_password
      authorize Member

      if (member = Member.find_by_email(member_params[:email])).nil?
        flash.alert = t('.email_not_found')
        return redirect_to action: :forgot_password
      end

      MemberMailer.with(member:).reset_password.deliver_later

      flash.notice = t('.password_reset')
      redirect_to_login
    end

    private

    def set_activation_token_purpose
      @token_purpose = :activation
    end

    def set_password_reset_token_purpose
      @token_purpose = :password_reset
    end

    def find_member_by_token
      @member = authorize Member.find_by_token_for!(@token_purpose, params[:token])
    end

    def update_password(fallback_view, notice)
      @member.assign_attributes(member_params.permit(:password, :password_confirmation))
      return render action: fallback_view unless @member.valid?

      log_in_user(@member)

      redirect_to members_root_path, notice: t(".#{notice}")
    end

    def member_params
      params.require(:members_member)
    end

    def handle_invalid_token
      redirect_to root_path, alert: t(".invalid_#{@token_purpose}_token")
    end

    def redirect_to_login
      redirect_to login_path
    end
  end
end
