# frozen_string_literal: true

class NewsletterSubscribersController < ApplicationController
  include SpamFiltering

  filters_spam_through_honeypot only: :create
  filters_spam_in_param proc { |params| params[:newsletter_subscriber][:last_name] }, max_length: 50, only: :create

  before_action :find_subscriber, except: %i[new create]

  def new
    @subscriber = authorize Newsletter::Subscriber.new
  end

  def edit; end

  def create
    authorize Newsletter::Subscriber

    @subscriber = create_subscriber
    if @subscriber.persisted?
      redirect_to root_path, notice: t('.created')
    else
      render :new
    end
  end

  def update
    flash.notice = t('application.saved_changes') if @subscriber.update(newsletter_params)
    redirect_to root_path
  end

  def confirm
    flash.notice = t('.confirmed') if @subscriber.confirm!
    redirect_to root_path
  end

  def destroy
    @subscriber.destroy
    redirect_to root_path, notice: t('.destroyed')
  end

  private

  def find_subscriber
    @subscriber = authorize Newsletter::Subscriber
                  .find_by!(token: params[:token])
  end

  def create_subscriber
    Newsletter::SubscriberCreateService.new(newsletter_params).execute
  end

  def newsletter_params
    permitted = %i[last_name gender privacy_terms]
    permitted << :email if @subscriber.nil? || @subscriber.new_record?
    params.expect(newsletter_subscriber: permitted)
  end
end
