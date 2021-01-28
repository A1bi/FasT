# frozen_string_literal: true

module Members
  class RenewMembershipsJob < ApplicationJob
    def perform
      members_to_renew.find_each(&:renew_membership!)

      SubmitMembershipFeeDebitsJob.perform_later
    end

    private

    def members_to_renew
      eligible_members.merge(new_members.or(members_due_for_renewal))
    end

    def new_members
      Member.where(membership_fee_paid_until: nil)
    end

    def members_due_for_renewal
      Member.where('membership_fee_paid_until < ?', Time.zone.today)
    end

    def eligible_members
      Member.where(membership_terminates_on: nil,
                   membership_fee_payments_paused: false)
    end
  end
end
