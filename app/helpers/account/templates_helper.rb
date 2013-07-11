require 'template_path'

module Account::TemplatesHelper
  def render_template_edit(template, index = 0)
    return '' if template.nil?
    content = ''
    if template.is_a?(Element)
      content = template.content
      template = template.template
    end
    html = ''
    if index.to_i == 0
      folder_name = template.folder_name
      template.paths do |js, css|
        js.each do |v|
          html << bk_javascript_include_tag("#{folder_name}/#{v.path}")
        end
        css.each do |v|
          html << bk_stylesheet_link_tag("#{folder_name}/#{v.path}")
        end
      end
    end
    html << "<div class='edit_element' template='#{template.name},#{template.version}' for='edit_#{template.name}_#{index}'>"
    html << render(
        :file => TemplatePath.edit_content(template),
        :locals => {
            :id => "edit_#{template.name}_#{index}",
            :dynamic_path => TemplatePath.path(template),
            :template_info => Hashie::Mash.new(template.description),
            :default => content
        }
    )
    html << link_to(t('remove'), 'javascript:void(0)', :id => 'remove_tag', :onclick => 'remove_tag(this)')
    html << '</div>'
    raw html
  end

  def get_view(path)
    Dir.foreach(path) do |file|
      return file unless file.match(/^content.[\w.]+/).nil?
    end
    nil
  end

  def render_template_edit_nr(template, index = 0)
    return '' if template.nil?
    html = ''
    if index.to_i == 0
      folder_name = template.folder_name
      template.paths do |js, css|
        js.each do |v|
          html << bk_javascript_include_tag("#{folder_name}/#{v.path}")
        end
        css.each do |v|
          html << bk_stylesheet_link_tag("#{folder_name}/#{v.path}")
        end
      end
    end
    html << "<div class='edit_element' template='#{template.name},#{template.version}' for='edit_#{template.name}_#{index}'>"
    html << render(
        :file => TemplatePath.edit_content(template),
        :locals => {
            :id => "edit_#{template.name}_#{index}",
            :dynamic_path => TemplatePath.path(template),
            :template_info => Hashie::Mash.new(template.description),
            :default => ''
        }
    )
    html << '</div>'
    raw html
  end

  def javascript_defer_tag(check_code, path, ops = {})
    render partial: 'account/templates/script', locals: {
        options:ops,
        insert_content_path:path,
        check_code:check_code
    }
  end

  def assets_path(template, path)
    "#{CONFIG.static_temp_site}/#{template.name}-#{template.version}/#{path}"
  end
end
