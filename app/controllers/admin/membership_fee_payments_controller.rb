# frozen_string_literal: true

module Admin
  class MembershipFeePaymentsController < ApplicationController
    def mark_as_failed
      payment = authorize Members::MembershipFeePayment.find(params[:id])
      payment.update(failed: true)

      member = payment.member
      previous_payment = member.membership_fee_payments
                               .where(failed: false).last
      member.update(
        membership_fee_paid_until: previous_payment&.paid_until,
        membership_fee_payments_paused: true
      )

      redirect_to [:admin, payment.member], notice: t('.marked_as_failed')
    end
  end
end
