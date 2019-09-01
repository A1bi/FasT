class NewsletterSubscribersController < ApplicationController
  skip_verify_authorized

  before_action :find_subscriber, except: :create

  def create
    @subscriber = create_subscriber
    if @subscriber.persisted?
      flash.notice = t('.created')
      redirect_to root_path
    else
      render :new
    end
  end

  def edit; end

  def update
    if @subscriber.update(newsletter_params)
      flash.notice = t('application.saved_changes')
    end
    redirect_to root_path
  end

  def confirm
    flash.notice = t('.confirmed') if @subscriber.confirm!
    redirect_to root_path
  end

  def destroy
    @subscriber.destroy
    flash.notice = t('.destroyed')
    redirect_to root_path
  end

  private

  def find_subscriber
    @subscriber = Newsletter::Subscriber.find_by(token: params[:token])
    return redirect_to root_path if @subscriber.nil?
  end

  def create_subscriber
    Newsletter::SubscriberCreateService.new(newsletter_params, false).execute
  end

  def newsletter_params
    permitted = %w[last_name gender privacy_terms]
    permitted << :email if @subscriber.nil? || @subscriber.new_record?
    params.require(:newsletter_subscriber).permit(permitted)
  end
end
