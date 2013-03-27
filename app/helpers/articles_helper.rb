module ArticlesHelper
  def render_element(element)
    template = element.template
    #如果模板丢失就显示默认样式
    return raw("<p title='#{t('templates.error')}' style='background-color: red'>#{element.content}</p>") if template.nil?

    @index ||= {}
    now = @index[template.name] || 0
    html = ''
    if now == 0 and !template.skim_script_path.nil?
      scripts = template.skim_script_path.split ',' || []
      scripts.each do |v|
        html << javascript_include_tag(v)
      end
    end
    #'/home/gen/Project/simple-text/skim_model/view/content.html.haml'
    html << render(:file => "#{template.file_path}/skim_model/view/content" ,
                   :locals => {:id => "#{template.name}_#{now}",
                               :content => element.content})
    @index[template.name] = now + 1
    raw html
  end

end
