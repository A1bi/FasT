module ApplicationHelper
  def title(page_title)
    content_for :title, page_title.to_s
  end
  
  def include_js(filename)
    content_for :js_file, filename.to_s
  end
  
  def include_css(filename)
    content_for :css_file, filename.to_s
  end
  
  def cond_submit(form)
    if params[:action] == "new"
      value = "erstellen"
    else
      value = "speichern"
    end
    form.submit :value => value
  end
end
