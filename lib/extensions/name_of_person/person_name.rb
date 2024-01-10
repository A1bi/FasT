# frozen_string_literal: true

module NameOfPerson
  class PersonNameWithTitle < PersonName
    attr_reader :title

    def initialize(first, last = nil, title = nil)
      @title = title
      super(first, last)
    end

    def full
      @full ||= title.present? ? "#{title} #{super}" : super
    end

    def familiar
      @familiar ||= title.present? ? "#{title} #{super}" : super
    end

    def abbreviated
      @abbreviated ||= title.present? ? "#{title} #{super}" : super
    end

    def sorted
      @sorted ||= title.present? ? "#{super}, #{title}" : super
    end

    def last_with_title_sorted
      @last_with_title_sorted ||= title.present? ? "#{last}, #{title}" : last
    end
  end
end
