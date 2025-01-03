# frozen_string_literal: true

class WebAuthnController < ApplicationController
  include UserSession

  before_action :authorize, except: %i[destroy]

  def options_for_create
    current_user.update(webauthn_id: WebAuthn.generate_user_id) if current_user.webauthn_id.blank?

    options = WebAuthn::Credential.options_for_create(
      user: { id: current_user.webauthn_id, name: current_user.email, display_name: current_user.name.full },
      exclude: current_user.web_authn_credentials.pluck(:id),
      authenticator_selection: {
        resident_key: 'required'
      }
    )

    session[:web_authn_create_challenge] = options.challenge

    render json: options
  end

  def create
    credential = WebAuthn::Credential.from_create(params[:credential])
    credential.verify(session[:web_authn_create_challenge])

    current_user.web_authn_credentials.create!(
      id: credential.id,
      public_key: credential.public_key,
      aaguid: credential.response.aaguid,
      sign_count: credential.sign_count
    )

    flash.notice = t('.created')
    head :created
  rescue WebAuthn::Error => e
    flash.alert = t('.create_failed')
    head :bad_request
    Sentry.capture_exception(e)
  end

  def options_for_auth
    options = WebAuthn::Credential.options_for_get

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
    flash.notice = t('.destroyed')
    redirect_to edit_members_member_path
  end

  private

  def authorize(record = nil)
    super(record, policy_class: WebAuthnPolicy)
  end
end
