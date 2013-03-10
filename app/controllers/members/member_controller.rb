class Members::MemberController < Members::MembersController
	ignore_restrictions :only => [:activate, :finish_activation]
	
	def activate
		@member = Member.where(:activation_code => params[:code]).first
		redirect_to_login if !params[:code].present? || @member.nil?
	end
	
	def finish_activation
		@member = Member.find(params[:member][:id])
		return redirect_to_login if @member.activation_code != params[:member][:activation_code]
		
		@member.password = params[:member][:password]
		@member.password_confirmation = params[:member][:password_confirmation]
		if @member.valid?
			@member.activate
			@member.save
			redirect_to root_path
		else
			render :action => :activate
		end
	end
	
	def update
		if @_member.update_attributes(params[:member], :as => :member)
			redirect_to :action => :edit
		else
			render :action => :edit
		end
	end
	
	private
	
	def redirect_to_login
		redirect_to login_path
	end
end
