module ApplicationHelper
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
    if params[:action] == :new
      value = t("application.submit_create")
    else
      value = t("application.submit_save")
    end
    form.submit :value => value
  end

  def nl2br(text)
    h(text).gsub(/\n/, "<br />").html_safe
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
    (Rails.application.assets || Sprockets::Railtie.build_environment(Rails.application)).resolve(path).present?
  end

  def uppercase_file_extension(path)
    File.extname(path).delete('.').upcase
  end

  private

  def event_identifier_path(identifier, path_method)
    event = Ticketing::Event.find_by(identifier: identifier)
    event.present? ? method(path_method).call(event.slug) : nil
  end
end
