# frozen_string_literal: true

module Admin
  class NewslettersController < ApplicationController
    before_action :find_newsletter, except: %i[index new create]
    before_action :prepare_new_newsletter, only: %i[new create]
    before_action :prepare_subscriber_lists, only: %i[new edit show]
    before_action :update_newsletter, only: %i[create update]

    def index
      @newsletters = authorize Newsletter::Newsletter.all
    end

    def new; end

    def create; end

    def show; end

    def edit; end

    def update; end

    def finish
      flash.notice = t('.finished') if @newsletter.review!
      redirect_to_index
    end

    def approve
      flash.notice = t('.sent') if @newsletter.sent!
      redirect_to_index
    end

    def destroy
      flash.notice = t('.destroyed') if @newsletter.destroy
      redirect_to_index
    end

    private

    def find_newsletter
      @newsletter = authorize Newsletter::Newsletter.find(params[:id])
    end

    def prepare_new_newsletter
      @newsletter = authorize Newsletter::Newsletter.new
    end

    def prepare_subscriber_lists
      @subscriber_lists = Newsletter::SubscriberList.order(:name)
    end

    def update_newsletter
      render request.action unless @newsletter.update(newsletter_params)

      if send_preview?
        NewsletterMailingJob.perform_later(@newsletter.id,
                                           params[:preview_email])
        flash.notice = t('.preview_sent')
      else
        flash.notice = t('.saved')
      end

      redirect_to edit_admin_newsletter_path(@newsletter)
    end

    def send_preview?
      params[:send_preview_email].present? && params[:preview_email].present?
    end

    def newsletter_params
      params.require(:newsletter_newsletter)
            .permit(:subject, :body_html, :body_text, subscriber_list_ids: [])
    end

    def redirect_to_index
      redirect_to action: :index
    end
  end
end
