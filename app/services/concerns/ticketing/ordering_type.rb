module Ticketing
  module OrderingType
    extend ActiveSupport::Concern

    def type
      params[:type]
    end

    %w[web admin retail].each do |t|
      define_method("#{t}?") { type == t }
    end
  end
end
