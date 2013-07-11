module Account::SettingsHelper
  def domain_tag
    html = ''
    if current_user.domains.size == 0
      html << '<label>你还没有设置域名</label>'
      html << "<button id='domain-button' class='btn' href='#domain-modal' data-toggle='modal' type='button'>#{t 'set_domain'}</button>"
    else
      html << "<label class='uneditable-input'>#{current_user.host_domain.word}.myboka.com</label>"
      html << "<button id='domain-button' class='btn' href='#domain-modal' data-toggle='modal' type='button'>#{t 'set_domain'}</button>"
      html << "<a class='btn' href='#{account_edit_blog_path}'>编辑博客</a>"
    end
    raw html
  end
end
