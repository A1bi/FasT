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
    if params[:action] == :new
      value = t("application.submit_create")
    else
      value = t("application.submit_save")
    end
    form.submit :value => value
  end
  
  def delete_btn(obj, msg = "")
    data = { :confirm => msg } if msg
    link_to "X", obj, :method => :delete, :class => :delete, :title => t("application.btn_delete"), :data => data
  end
end
