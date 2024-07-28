# frozen_string_literal: true

module AnnouncementAlert
  extend ActiveSupport::Concern

  ALERT_FILE_PATH = Rails.public_path.join('uploads/index_alert.json')

  included do
    before_action :set_announcement_flash
  end

  private

  def set_announcement_flash
    flash.now[:announcement] = announcement_alert_text if show_announcement_alert?
  end

  def show_announcement_alert?
    File.exist? ALERT_FILE_PATH
  end

  def announcement_alert_text
    JSON.parse(File.read(ALERT_FILE_PATH))['text'].html_safe # rubocop:disable Rails/OutputSafety
  end
end
