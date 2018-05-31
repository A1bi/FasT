class NewsletterController < ApplicationController
  before_action :find_subscriber, except: :create

  def create
    @subscriber = Newsletter::Subscriber.new(newsletter_params)
    if @subscriber.save
      @subscriber.send_confirmation_instructions
      flash.notice = t("newsletter.subscriber.created")
      redirect_to root_path
    else
      render :new
    end
  end

  def edit
  end

  def update
    @subscriber.update_attributes(newsletter_params)
    flash.notice = t("application.saved_changes")
    redirect_to root_path
  end

  def confirm
    flash.notice = t('newsletter.subscriber.confirmed') if @subscriber.confirm!
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

  def newsletter_params
    permitted = %w[last_name gender privacy_terms]
    permitted << :email if @subscriber.nil? || @subscriber.new_record?
    params.require(:newsletter_subscriber).permit(permitted)
  end
end
