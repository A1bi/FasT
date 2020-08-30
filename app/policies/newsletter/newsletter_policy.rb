# frozen_string_literal: true

module Newsletter
  class NewsletterPolicy < ApplicationPolicy
    def index?
      user.permitted?(:newsletters_read)
    end

    def show?
      index?
    end

    def create?
      user.permitted?(:newsletters_update)
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
      user.permitted?(:newsletters_approve)
    end

    private

    def can_be_modified?
      record.draft? || (record.review? && approve?)
    end
  end
end
