class NewsletterController < ApplicationController
  before_filter :find_subscriber, except: :create
  
  def create
    @subscriber = Newsletter::Subscriber.new(params[:newsletter_subscriber])
    if @subscriber.save
      flash.notice = t("newsletter.subscriber.created")
      NewsletterMailer.subscribed(@subscriber).deliver
      redirect_to root_path
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    @subscriber.update_attributes(params[:newsletter_subscriber])
    flash.notice = t("application.saved_changes")
    redirect_to root_path
  end
  
  def destroy
    @subscriber.destroy
    flash.notice = t("newsletter.subscriber.destroyed")
    redirect_to root_path
  end
  
  private
  
  def find_subscriber
    @subscriber = Newsletter::Subscriber.where(token: params[:token]).first
    return redirect_to root_path if !@subscriber
  end
end