module Admin
  class NewsletterImagesController < AdminController
    def create
      @newsletter = authorize Newsletter::Newsletter.find(params[:newsletter_id])
      if @newsletter && !@newsletter.sent?
        @newsletter.images.create(params.require(:newsletter_image).permit(:image))
        redirect_to_newsletter
      else
        redirect_to admin_newsletters_path
      end
    end

    def destroy
      image = authorize Newsletter::Image.find(params[:id])
      image.destroy if image && !image.newsletter.sent?
      redirect_to_newsletter
    end

    private

    def redirect_to_newsletter
      redirect_to edit_admin_newsletter_path(params[:newsletter_id], anchor: :images)
    end

    def authorize(record, query = {})
      query[:policy_class] = Admin::NewsletterImagePolicy
      super
    end
  end
end
