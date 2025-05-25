# frozen_string_literal: true

class StaticPolicy < ApplicationPolicy
  def index?
    true
  end

  def agb?
    true
  end

  def impressum?
    true
  end

  def logo_generator?
    user_admin?(web_authn_required: false)
  end

  def privacy?
    true
  end

  def privacy_fallback?
    privacy?
  end

  def privacy_membership?
    privacy?
  end

  def satzung?
    true
  end

  def spielstaetten?
    true
  end

  def theaterkultur?
    true
  end

  def vereinsleben?
    true
  end

  def widerruf?
    true
  end
end
