class GbookEntrySweeper < ActionController::Caching::Sweeper
  observe GbookEntry
	
	def sweep_page_navis
		expire_fragment %r{gbook_page_navi/\d+}
	end
  
  def sweep_pages
    expire_fragment %r{gbook_page/\d+/(true|false)}
  end
	
	def after_update(entry)
		sweep_pages
	end
	
	def after_create(entry)
		sweep_pages
		sweep_page_navis
	end
  alias_method :after_destroy, :after_create
end