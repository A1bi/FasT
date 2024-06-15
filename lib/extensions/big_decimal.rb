# frozen_string_literal: true

module BigDecimalExtensions
  def as_json
    to_f
  end
end

BigDecimal.prepend BigDecimalExtensions
