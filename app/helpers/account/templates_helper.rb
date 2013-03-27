module Account::TemplatesHelper
  def render_template_edit(template, index = 0)
    return '' if template.nil?
    content = ''
    if template.is_a?(Element)
      content = template.content
      template = template.template
    end
    html = ''
    if index.to_i == 0 and !template.edit_script_path.nil?
      scripts = template.edit_script_path.split ',' || []
      scripts.each do |v|
        html << javascript_include_tag(v)
      end
    end
    html << "<div class='edit_element' template_name='#{template.name}' for='#{template.name}_#{index}'>"
    html << render(
        :file => "#{template.file_path}/edit_model/view/content.html.haml",
        :locals => {
            :id => "#{template.name}_#{index}",
            :default => content
        }
    )
    html << link_to(t('remove'), 'javascript:void(0)', :id => 'remove_tag', :onclick => 'remove_tag(this)')
    html << '</div>'
    raw html
  end
end
