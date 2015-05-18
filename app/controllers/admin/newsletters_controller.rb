module Admin
	class NewslettersController < BaseController
    before_action :find_newsletter, only: [:show, :edit, :update, :destroy, :deliver]
    before_action :prepare_new_newsletter, :only => [:new, :create]
    before_action :redirect_if_sent, only: [:edit, :update, :deliver, :destroy]
    before_action :update_newsletter, only: [:create, :update]

    def index
      @newsletters = Newsletter::Newsletter.all
    end

    def new
    end

    def create
    end

    def edit
    end

    def update
    end

    def destroy
      @newsletter.destroy
      redirect_to :action => :index
    end

    def deliver
      Resque.enqueue(NewsletterMailingJob, @newsletter.id)
      @newsletter.update(sent: Time.now)

      flash.notice = t("admin.newsletters.sent")
      redirect_to :action => :index
    end

    private

    def find_newsletter
      @newsletter = Newsletter::Newsletter.find(params[:id])
    end

    def prepare_new_newsletter
      @newsletter = Newsletter::Newsletter.new
    end

    def redirect_if_sent
      if @newsletter.sent?
        redirect_to action: :index
        return false
      end
    end

    def update_newsletter
      @newsletter.assign_attributes(params.require(:newsletter_newsletter).permit(:subject, :body_html, :body_text))
      @newsletter.save

      if params[:preview_email].present?
        Resque.enqueue(NewsletterMailingJob, @newsletter.id, params[:preview_email])

        flash.notice = t("admin.newsletters.preview_sent")
        redirect = edit_admin_newsletter_path(@newsletter)
      else
        redirect = { action: :index }
      end

      redirect_to redirect
    end
  end
end
