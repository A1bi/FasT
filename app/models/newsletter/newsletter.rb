class Newsletter::Newsletter < BaseModel
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::AssetTagHelper

  has_and_belongs_to_many :subscriber_lists
  has_many :subscribers, ->{ confirmed }, through: :subscriber_lists
  has_many :images

  enum status: %i[draft review sent]

  alias_attribute :recipients, :subscribers

  validates :subject, presence: true
  validates :body_text, presence: true

  IMAGE_REGEXP = /%%bild_(\d+)%%/

  def review!
    return unless draft?

    super

    BaseMailer.mail(to: Settings.newsletters.review_email, subject: Settings.newsletters.review_subject, body: '').deliver
  end

  def sent!
    return unless review?

    super
    self.sent_at = Time.current

    NewsletterMailingJob.perform_later(id)
  end

  def body_text_final
    body_text.gsub(IMAGE_REGEXP, '')
  end

  def body_html_final
    if body_html.present? && body_html.length > 5
      body_html
    else
      html = simple_format(body_text)
      html.gsub!(/<p>((%%bild_\d+%%)+)<\/p>/, '<p style="text-align: center;">\1</p>')
      html.gsub!(IMAGE_REGEXP) do |match|
        image = images.find_by_id(match.match(/\d+/).to_s)
        if image.present?
          link_to(image_tag(image.image.url(:mail), alt: ''), image.image.url(:big))
        else
          ''
        end
      end
      html
    end
  end
end
