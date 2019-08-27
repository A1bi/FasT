module Admin
  module MembersHelper
    def last_login_time(member)
      if member.last_login.nil?
        return content_tag :em, t('admin.members.never_logged_in')
      end

      l member.last_login, format: '%-d. %B %Y, %H:%M Uhr'
    end
  end
end
