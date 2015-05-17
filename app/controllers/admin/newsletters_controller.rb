module Admin
	class NewslettersController < BaseController
    before_action :find_newsletter, only: [:edit, :update, :destroy, :deliver]
    before_filter :prepare_new_newsletter, :only => [:new, :create]
    before_action :update_newsletter, only: [:create, :update]

    def index
      @newsletters = Newsletter::Newsletter.all
    end

    def new
    end

    def create
      @newsletter.save
      redirect_to :action => :index
    end

    def edit
    end

    def update
      @newsletter.save
      redirect_to :action => :index
    end

    def destroy
      @newsletter.destroy if @newsletter.sent.nil?
      redirect_to :action => :index
    end

    def deliver
      Resque.enqueue(NewsletterMailingJob, @newsletter.id)
      @newsletter.update(sent: Time.now)
      redirect_to :action => :index
    end

    private

    def find_newsletter
      @newsletter = Newsletter::Newsletter.find(params[:id])
    end

    def prepare_new_newsletter
      @newsletter = Newsletter::Newsletter.new
    end

    def update_newsletter
			@newsletter.assign_attributes(params.require(:newsletter_newsletter).permit(:subject, :body_html, :body_text))
		end
  end
end
