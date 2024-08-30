# frozen_string_literal: true

module Newsletter
  class Newsletter < ApplicationRecord
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::AssetTagHelper

    has_and_belongs_to_many :subscriber_lists
    has_many :recipients, -> { confirmed }, through: :subscriber_lists, source: :subscribers
    has_many :images, dependent: :destroy

    enum :status, %i[draft review sent]

    validates :subject, presence: true
    validates :body_text, presence: true

    IMAGE_REGEXP = /%%bild_(\d+)%%/

    def review!
      return unless draft?

      send_review_notification if super
    end

    def sent!
      return unless review?

      update(status: :sent, sent_at: Time.current)

      MailingJob.perform_later(self)
    end

    def body_text_final
      remove_image_placeholder
    end

    def body_html_final
      html = if body_html.present? && body_html.length > 5
               body_html
             else
               body_html_from_text
             end
      fill_image_placeholder(html)
    end

    private

    def remove_image_placeholder
      body_text.gsub(IMAGE_REGEXP, '')
    end

    def body_html_from_text
      simple_format(body_text)
        .gsub(%r{<p>((%%bild_\d+%%)+)</p>}, '<p style="text-align: center;">\1</p>')
    end

    def fill_image_placeholder(html)
      html.gsub(IMAGE_REGEXP) do |match|
        image = images.find_by(id: match.match(/\d+/).to_s)
        next '' if image.nil?

        link_to(image_tag(image.image.url(:mail), alt: ''), image.image.url(:big))
      end
    end

    def send_review_notification
      ApplicationMailer.mail(to: Settings.newsletters.review_email,
                             subject: Settings.newsletters.review_subject,
                             body: "Newsletter: #{subject}")
                       .deliver_later
    end
  end
end
