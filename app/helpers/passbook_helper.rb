# frozen_string_literal: true

module PassbookHelper
  def rgb_color(values)
    "rgb(#{values.join(', ')})"
  end
end
