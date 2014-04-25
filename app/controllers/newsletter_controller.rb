class NewsletterController < ApplicationController
  def create
    @subscriber = Newsletter::Subscriber.new(params[:newsletter_subscriber])
    if @subscriber.save
      flash.notice = t("newsletter.subscriber.created")
      redirect_to root_path
    else
      render :new
    end
  end
end