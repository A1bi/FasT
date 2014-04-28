module Admin
	class MembersController < BaseController
		before_filter :find_groups, :only => [:new, :edit, :create, :update]
		before_filter :find_member, :only => [:edit, :update, :destroy, :reactivate]
		before_filter :prepare_new_member, :only => [:new, :create]
		before_filter :update_member, :only => [:create, :update]
	
	  def index
	    @members = Members::Member.order(:last_name).order(:first_name)
	  end
	
		def new
		end
	
		def create
			@member.reset_password
			if @member.save
				send_activation_mail if params[:activation][:send] == "1"
			
				redirect_to :action => :index
			else
				render :action => :new
			end
		end
	
		def edit
		end
	
		def update
			if @member.save
				redirect_to edit_admin_members_member_path(@member), notice: t("application.saved_changes")
			else
				render :action => :edit
			end
		end
	
		def destroy
			@member.destroy
			redirect_to :action => :index
		end
    
    def reactivate
      @member.last_login = nil
      @member.reset_password
      send_activation_mail if @member.save
      
      redirect_to edit_admin_members_member_path(@member), notice: t("admin.members.sent_activation_mail")
    end
    
		protected
	
		def find_groups
			@groups = [];
			Members::Member.groups.each do |id, name|
				@groups << [t("members.groups." + name.to_s), id]
			end
		end
	
		def find_member
			@member = Members::Member.find(params[:id])
		end
	
		def prepare_new_member
			@member = Members::Member.new
		end
	
		def update_member
			@member.email_can_be_blank = true
			@member.assign_attributes(params.require(:members_member).permit(:email, :first_name, :last_name, :nickname, :group, :birthday))
		end
    
  	def send_activation_mail
  		MemberMailer.activation(@member).deliver
  	end
	end
end
