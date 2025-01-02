# frozen_string_literal: true

class WebAuthnPolicy < ApplicationPolicy
  def options_for_create?
    create?
  end

  def create?
    user.present?
  end

  def options_for_auth?
    auth?
  end

  def auth?
    true
  end

  def destroy?
    create? && record.user == user
  end
end
