# frozen_string_literal: true

class HealthController < Rails::HealthController
  def show
    verify_database_connection
    return render_down unless sidekiq_healthy?

    render_up
  end

  private

  def verify_database_connection
    ActiveRecord::Base.connection.verify!
  end

  def sidekiq_healthy?
    Sidekiq::ProcessSet.new.any?
  end
end
