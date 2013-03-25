class GallerySweeper < ActionController::Caching::Sweeper
  observe Gallery
	
	def after_update(gallery)
		scope = [:galleries, :index, :all]
		expire_fragment scope.flatten.push(:true)
		expire_fragment scope.flatten.push(:false)
	end
	alias_method :after_create, :after_update
	alias_method :after_destroy, :after_update
end