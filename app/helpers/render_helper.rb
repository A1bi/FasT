# frozen_string_literal: true

module RenderHelper
  def render_inline(template, options = {})
    # remove final newline from partial
    # so it will not add whitespace to mail content
    # or even line breaks in text mails

    # rubocop:disable Rails/OutputSafety
    render(template, options).chomp.html_safe
    # rubocop:enable Rails/OutputSafety
  end
end
