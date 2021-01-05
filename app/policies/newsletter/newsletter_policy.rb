# frozen_string_literal: true

module Newsletter
  class NewsletterPolicy < ApplicationPolicy
    def index?
      user_permitted?(:newsletters_read)
    end

    def show?
      index?
    end

    def create?
      user_permitted?(:newsletters_update)
    end

    def update?
      create? && can_be_modified?
    end

    def destroy?
      create? && can_be_modified?
    end

    def finish?
      create?
    end

    def approve?
      user_permitted?(:newsletters_approve)
    end

    private

    def can_be_modified?
      record.draft? || (record.review? && approve?)
    end
  end
end
