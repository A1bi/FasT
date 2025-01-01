# frozen_string_literal: true

class WebAuthnController < ApplicationController
  before_action :authorize, except: %i[destroy]

  def options_for_create
    current_user.update(webauthn_id: WebAuthn.generate_user_id) if current_user.webauthn_id.blank?

    options = WebAuthn::Credential.options_for_create(
      user: { id: current_user.webauthn_id, name: current_user.email, display_name: current_user.name.full },
      exclude: current_user.web_authn_credentials.pluck(:id)
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
