module GbookHelper
  def render_pages
    output = ""
    
		pages = (GbookEntry.count.to_f / @steps.to_f).ceil;
    pages.times do |i|
      if @page != i+1
        output += link_to i+1, gbook_entries_path(:page => i+1)
      else
        output += (i+1).to_s
      end
      
      if i != pages-1
        output += ", "
      end
    end
    
    return output.html_safe
  end
end
