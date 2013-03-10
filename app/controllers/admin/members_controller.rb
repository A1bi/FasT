class Admin::MembersController < Admin::AdminController
	
	before_filter :find_groups, :only => [:new, :edit, :create, :update]
	before_filter :find_member, :only => [:edit, :update, :destroy]
	before_filter :prepare_new_member, :only => [:new, :create]
	before_filter :update_member, :only => [:create, :update]
	
  def index
    @members = Member.order(:last_name).order(:first_name)
  end
	
	def new
	end
	
	def create
		@member.set_random_password
		if @member.save
			redirect_to :action => :index
		else
			render :action => :new
		end
	end
	
	def edit
	end
	
	def update
		if @member.save
			redirect_to edit_admin_member_path(@member)
		else
			render :action => :edit
		end
	end
	
	def destroy
		@member.destroy
		redirect_to :action => :index
	end
	
	protected
	
	def find_groups
		@groups = [];
		Member.groups.each do |id, name|
			@groups << [t("members.groups." + name.to_s), id]
		end
	end
	
	def find_member
		@member = Member.find(params[:id])
	end
	
	def prepare_new_member
		@member = Member.new
	end
	
	def update_member
		@member.assign_attributes(params[:member], :as => :admin)
	end
end
