class Newsletter::Newsletter < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::AssetTagHelper

  has_many :images

  IMAGE_REGEXP = /%%bild_(\d+)%%/

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

  def sent?
    sent.present?
  end
end
