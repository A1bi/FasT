# frozen_string_literal: true

module Admin
  class NewsletterImagesController < ApplicationController
    def create
      @newsletter = Newsletter::Newsletter.find(params[:newsletter_id])
      image = authorize @newsletter.images.build
      image.update(newsletter_image_params)
      redirect_to_newsletter
    end

    def destroy
      authorize(Newsletter::Image.find(params[:id])).destroy
      redirect_to_newsletter
    end

    private

    def redirect_to_newsletter
      redirect_to edit_admin_newsletter_path(params[:newsletter_id],
                                             anchor: :images)
    end

    def newsletter_image_params
      params.require(:newsletter_image).permit(:image)
    end
  end
end
