# frozen_string_literal: true

module Admin
  module MembersHelper
    def last_login_time(member)
      return tag.em t('admin.members.never_logged_in') if member.last_login.nil?

      l member.last_login, format: '%-d. %B %Y, %H:%M Uhr'
    end

    def last_membership_fee_payment_date(member)
      payment = member.membership_fee_payments.last
      return tag.em t('admin.members.membership_fee_never_paid') if payment.nil?

      l payment.created_at.to_date, format: :long
    end

    def obfuscated_mandate_iban(mandate)
      return nil if mandate&.iban.blank?

      # do not obfuscate if the user has just entered this IBAN and it
      # was not saved yet, so the user is able to see his invalid input
      return mandate.iban if mandate.will_save_change_to_iban?

      iban = mandate.iban
      iban[0..1] + 'X' * (iban.length - 5) + iban[-3..]
    end
  end
end
