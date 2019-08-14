module Admin
  module MembersHelper
    def member_joined_date(member)
      if member.created_at < Date.new(2013, 4, 1)
        return content_tag(:em, t('admin.members.joined_date_unknown'))
      end

      l member.created_at.to_date, format: '%-d. %B %Y'
    end

    def last_login_time(member)
      if member.last_login.nil?
        return content_tag :em, t('admin.members.never_logged_in')
      end

      l member.created_at.to_date, format: '%-d. %B %Y, %H:%M Uhr'
    end
  end
end
