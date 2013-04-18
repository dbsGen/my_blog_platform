module ArticlesHelper
  def render_element(element)
    template = element.template
    #如果模板丢失就显示默认样式
    return raw("<p title='#{t('templates.error')}' style='background-color: red'>#{element.content}</p>") if template.nil?

    @index ||= {}
    now = @index[template.name] || 0
    html = ''
    if now == 0 and
      template.paths('skim_path') do |js, css|
        js.each do |v|
          html << javascript_include_tag("#{CONFIG['static_temp_site']}/#{folder_name}/#{v.path}")
        end
        css.each do |v|
          html << stylesheet_link_tag("#{CONFIG['static_temp_site']}/#{folder_name}/#{v.path}")
        end
      end
    end

    file_path = "#{template.dynamic_path}skim/view"
    cf = get_view file_path
    html << render(:file => "#{template.dynamic_path}/skim/view/#{cf}" ,
                   :locals => {:id => "#{template.name}_#{now}",
                               :element => element,
                               :dynamic_path => template.dynamic_path,
                               :static_path => template.static_path,
                               :template_info => template.description
                   })
    @index[template.name] = now + 1
    raw html
  end

end
