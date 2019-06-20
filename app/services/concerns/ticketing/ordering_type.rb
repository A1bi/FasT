module Ticketing
  module OrderingType
    extend ActiveSupport::Concern

    included do
      helper_method :web?, :retail?, :admin?
    end

    def type
      params[:type].to_sym
    end

    %i[admin retail].each do |t|
      define_method("#{t}?") { type == t }
    end

    def web?
      !admin? && !retail?
    end
  end
end
