module Admin
  module MembersHelper
    def last_login_time(member)
      if member.last_login.nil?
        return content_tag :em, t('admin.members.never_logged_in')
      end

      l member.last_login, format: '%-d. %B %Y, %H:%M Uhr'
    end

    def obfuscated_mandate_iban(mandate)
      # do not obfuscate if the user has just entered this IBAN and it
      # was not saved yet, so the user is able to see his invalid input
      return mandate.iban if mandate.will_save_change_to_iban?

      iban = mandate.iban
      iban[0..1] + 'X' * (iban.length - 5) + iban[-3..-1]
    end
  end
end
