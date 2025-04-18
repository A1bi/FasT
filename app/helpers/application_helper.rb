# frozen_string_literal: true

module ApplicationHelper
  include RenderHelper

  NUM_COLOR_THEMES = 5

  def title(page_title)
    content_for :title, page_title.to_s
  end

  def cond_submit(form)
    action = params[:action] == :new ? :create : :save
    form.submit value: t("application.submit.#{action}"), class: :btn
  end

  def asset_exists?(path)
    (
      Rails.application.assets ||
      Sprockets::Railtie.build_environment(Rails.application)
    ).find_asset(path).present?
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
        concat tag.small(affiliation, class: 'd-block text-body-secondary') if affiliation.present?
      end
    elsif affiliation.present?
      affiliation
    else
      tag.em missing_notice
    end
  end

  def honeypot_field
    text_area_tag :comment, nil, 'aria-hidden': true, tabindex: -1,
                                 class: 'honeypot'
  end

  def obfuscated_iban(iban)
    return if iban.blank?

    iban[0..1] + 'X' * (iban.length - 5) + iban[-3..]
  end

  def formatted_iban(iban)
    iban.gsub(/(.{4})/, '\1 ').strip
  end

  def event_logo(event, tag: :h2, image_options: {}, inline_svg: false)
    return content_tag(tag, event.name) if (path = event_logo_path(event)).nil?
    return inline_svg(path) if inline_svg

    image_tag(path, { **image_options, alt: event.name })
  end

  def event_logo_path(event)
    path = "events/#{event.assets_identifier}/title.svg"
    path if asset_exists?(path)
  end

  def inline_svg(filename)
    file_path = Rails.root.join("app/assets/images/#{filename}")
    content = File.read(file_path)
    content.gsub(/<(\?xml|!DOCTYPE).*?>/, '').html_safe # rubocop:disable Rails/OutputSafety
  end

  def color_theme_index
    unless session[:color_theme_expires_at]&.future?
      previous_index = session.fetch(:color_theme_index, rand(NUM_COLOR_THEMES))
      session[:color_theme_index] = (previous_index + 1) % NUM_COLOR_THEMES
      session[:color_theme_expires_at] = 1.hour.from_now
    end

    session[:color_theme_index]
  end
end
