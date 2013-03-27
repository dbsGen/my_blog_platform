module Account::ArticlesHelper
  def render_edit(template)
    begin
      name = template.is_a?(Element) ? template.template.name : template.name
    rescue Exception => e
      logger.error("There is no template, #{e}")
      return ''
    end

    @index ||= {}
    now = @index[name] || 0
    html = ''
    html << render_template_edit(template, now)
    @index[name] = now + 1
    raw html
  end

  def render_edits(elements)
    html = '<div id="edit_content">'
    elements ||= []
    if elements.size > 0
      elements.each do |element|
        html << render_edit(element)
      end
    else
      html << <<-script
<div  style='text-align:center; height:30px; margin-top:10px'>
  <b>#{t('no_element')}</b>
</div>
      script
    end

    html << '</div>'
    raw html
  end
end
