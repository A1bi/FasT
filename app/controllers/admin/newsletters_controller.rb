module Admin
  class NewslettersController < BaseController
    before_action :find_newsletter, only: [:show, :edit, :update, :destroy, :finish]
    before_action :prepare_new_newsletter, :only => [:new, :create]
    before_action :prepare_subscriber_lists, :only => [:new, :edit, :show]
    before_action :redirect_if_sent, only: [:edit, :update, :finish, :destroy]
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

    def finish
      @newsletter.review!

      flash.notice = t("admin.newsletters.finished")
      redirect_to :action => :index
    end

    private

    def find_newsletter
      @newsletter = Newsletter::Newsletter.find(params[:id])
    end

    def prepare_new_newsletter
      @newsletter = Newsletter::Newsletter.new
    end

    def prepare_subscriber_lists
      @subscriber_lists = Newsletter::SubscriberList.order(:name)
    end

    def redirect_if_sent
      if @newsletter.sent?
        redirect_to action: :index
        return false
      end
    end

    def update_newsletter
      @newsletter.assign_attributes(params.require(:newsletter_newsletter).permit(:subject, :body_html, :body_text, subscriber_list_ids: []))
      @newsletter.save

      if params[:send_preview_email].present? && params[:preview_email].present?
        NewsletterMailingJob.perform_later(@newsletter.id, params[:preview_email])

        flash.notice = t("admin.newsletters.preview_sent")
      end

      redirect_to edit_admin_newsletter_path(@newsletter)
    end
  end
end
