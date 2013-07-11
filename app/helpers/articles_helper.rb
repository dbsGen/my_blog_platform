require 'template_path'

module ArticlesHelper
  def render_element(element)
    template = element.template
    element = Element_copy.new element
    element.content = replace_tp_tag(element.content)
    #如果模板丢失就显示默认样式
    return raw("<p title='#{t('templates.error')}' style='background-color: red'>#{element.content}</p>") if template.nil?

    @index ||= {}
    now = @index[template.name] || 0
    html = ''
    if now == 0 and
      template.paths('skim_path') do |js, css|
        js.each do |v|
          html << bk_javascript_include_tag("#{template.folder_name}/#{v.path}")
        end
        css.each do |v|
          html << bk_stylesheet_link_tag("#{template.folder_name}/#{v.path}")
        end
      end
    end
    html << render(:file => TemplatePath.skim_content(template) ,
                   :locals => {:id => "#{template.name}_#{now}",
                               :element => element,
                               :dynamic_path => TemplatePath.path(template),
                               :template_info => template.description
                   })
    @index[template.name] = now + 1
    raw html
  end

  def comments_pagination_tag(total, index)
    return '' if total == 1
    start = [1, index - 4].max
    stop = [total, index + 4].min
    a_id = @article.id
    render partial: 'articles/comments_pagination',
           locals: {total: total, index: index, start: start, stop: stop, a_id: a_id}
  end
end
