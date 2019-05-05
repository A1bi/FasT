module PassbookHelper
  def rgb_color(values)
    "rgb(#{values.join(', ')})"
  end

  def w3c_date(date)
    date.to_formatted_s(:w3c)
  end
end
