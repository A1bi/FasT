# frozen_string_literal: true

class WebAuthnController < ApplicationController
  include UserSession

  USER_VERIFICATION = 'required'

  before_action :authorize, except: %i[destroy]
  before_action :ensure_user_present, only: %i[options_for_create create]

  rescue_from ActiveSupport::MessageVerifier::InvalidSignature, with: :handle_invalid_activation_token

  def options_for_create
    user.update(webauthn_id: WebAuthn.generate_user_id) if user.webauthn_id.blank?

    options = WebAuthn::Credential.options_for_create(
      user: { id: user.webauthn_id, name: user.email, display_name: user.name.full },
      exclude: user.web_authn_credentials.pluck(:id),
      authenticator_selection: {
        resident_key: 'required',
        user_verification: USER_VERIFICATION
      },
      attestation: 'indirect'
    )

    session[:web_authn_create_challenge] = options.challenge

    render json: options
  end

  def create
    return head :bad_request if params[:credential].blank?

    credential = WebAuthn::Credential.from_create(params[:credential])
    credential.verify(session[:web_authn_create_challenge])

    user.web_authn_credentials.create!(
      id: credential.id,
      public_key: credential.public_key,
      aaguid: credential.response.aaguid,
      sign_count: credential.sign_count
    )

    if activation_token.present?
      log_in_user(user)

      flash.notice = t('.activated')
      render json: { goto_path: members_root_path }

    else
      flash.notice = t('.created')
      head :created
    end
  rescue WebAuthn::Error => e
    flash.alert = t('.create_failed')
    head :bad_request
    Sentry.capture_exception(e)
  end

  def options_for_auth
    options = WebAuthn::Credential.options_for_get(
      user_verification: USER_VERIFICATION
    )

    session[:web_authn_auth_challenge] = options.challenge

    render json: options
  end

  def auth
    credential = WebAuthn::Credential.from_get(params[:credential])
    credential_record = WebAuthnCredential.find(credential.id)

    credential.verify(
      session[:web_authn_auth_challenge],
      public_key: credential_record.public_key,
      sign_count: credential_record.sign_count
    )

    credential_record.update!(sign_count: credential.sign_count)

    log_in_user(credential_record.user)

    render json: { goto_path: }
  rescue WebAuthn::Error, ActiveRecord::RecordNotFound => e
    flash.alert = t('.auth_failed')
    head :bad_request
    Sentry.capture_exception(e)
  end

  def destroy
    authorize(current_user.web_authn_credentials.find(params[:id])).destroy
    redirect_to edit_members_member_path, notice: t('.destroyed')
  end

  private

  def user
    @user ||= activation_token.present? ? User.find_by_token_for!(:activation, activation_token) : current_user
  end

  def ensure_user_present
    user_not_authorized if user.nil?
  end

  def authorize(record = nil)
    super(record, policy_class: WebAuthnPolicy)
  end

  def activation_token
    params[:activation_token]
  end

  def handle_invalid_activation_token
    head :bad_request
  end
end
