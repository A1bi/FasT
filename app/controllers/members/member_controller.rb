module Members
	class MemberController < BaseController
		ignore_restrictions :only => [:activate, :finish_activation, :forgot_password]
	
		def activate
			@member = Member.where(:activation_code => params[:code]).first
			redirect_to_login if !params[:code].present? || @member.nil?
		end
	
		def finish_activation
			@member = Member.find(params[:members_member][:id])
			return redirect_to_login if @member.activation_code != params[:members_member][:activation_code]
		
			@member.password = params[:members_member][:password]
			@member.password_confirmation = params[:members_member][:password_confirmation]
			if @member.valid?
				@member.activate
			
				session[:user_id] = @member.id
			
				flash.notice = (@member.last_login) ? t("members.member.password_changed") : t("members.member.activated")
				redirect_to members_root_path
        
				@member.logged_in
				@member.save
			else
				render :action => :activate
			end
		end
	
		def update
			if @_member.update_attributes(params[:members_member], :as => :member)
				flash.notice = t("application.saved_changes")
				redirect_to :action => :edit
			else
				render :action => :edit
			end
		end
    
    def reset_password
      member = Member.where(email: params[:members_member][:email]).first
      if !member
        flash.alert = t("members.member.email_not_found")
				redirect_to :action => :forgot_password
      else
        member.set_activation_code
        member.save
        
        MemberMailer.reset_password(member).deliver
        
        flash.notice = t("members.member.password_reset")
				redirect_to_login
      end
    end
	
		private
	
		def redirect_to_login
			redirect_to members_login_path
		end
	end
end
