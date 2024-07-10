# frozen_string_literal: true

module BigDecimalExtensions
  def as_json(_options = nil)
    to_f
  end
end

BigDecimal.prepend BigDecimalExtensions
