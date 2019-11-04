module ApplicationHelper
  include RenderHelper

  def title(page_title)
    content_for :title, page_title.to_s
  end

  def include_js(filename)
    content_for :js_file, filename.to_s
  end

  def include_css(filename)
    content_for :css_file, filename.to_s
  end

  def cond_submit(form)
    action = params[:action] == :new ? :create : :save
    form.submit value: t("application.submit.#{action}")
  end

  def theater_play_identifier_path(identifier)
    event_identifier_path(identifier, :theater_play_path)
  end

  def dates_event_identifier_path(identifier)
    event_identifier_path(identifier, :dates_event_path)
  end

  def new_ticketing_order_identifier_path(identifier)
    event_identifier_path(identifier, :new_ticketing_order_path)
  end

  def info_identifier_path(identifier)
    event_identifier_path(identifier, :info_path)
  end

  def asset_exists?(path)
    (
      Rails.application.assets ||
      Sprockets::Railtie.build_environment(Rails.application)
    ).resolve(path).present?
  end

  def uppercase_file_extension(path)
    File.extname(path).delete('.').upcase
  end

  def sorted_name(record)
    capture do
      concat record.last_name.to_s
      concat ', ' if record.last_name.present? && record.first_name.present?
      concat record.first_name if record.first_name
    end
  end

  def name_and_affiliation(name, affiliation, missing_notice)
    if name.present?
      capture do
        concat name
        concat content_tag(:em, " (#{affiliation})") if affiliation.present?
      end
    elsif affiliation.present?
      affiliation
    else
      content_tag :em, missing_notice
    end
  end

  private

  def event_identifier_path(identifier, path_method)
    event = Ticketing::Event.find_by(identifier: identifier)
    event.present? ? method(path_method).call(event.slug) : nil
  end
end
