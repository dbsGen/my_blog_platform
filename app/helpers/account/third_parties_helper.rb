module Account::ThirdPartiesHelper
  def third_party_tag(value, type, path)
    path ||= '#'
    html = "<div id='#{type}'>"
    if !value.nil? and value.length > 0
      html << text_field_tag("#{type}-text", value, :disabled => true, :class => 'span3')
      html << link_to(t('delete'),
                      account_TP_delete_path(type),
                      :class => 'btn btn-danger',
                      :method => 'delete',
                      :remote => true
      )
    else
      html << link_to(t('third_parties.set'),
                      path,
                      :class => 'btn btn-primary iframe',
                      :id => "#{type}-button"
      )
    end
    html << '</div>'
    raw html
  end

  def baidu_yun_name
    info = current_user.baidu_yun_info
    info.nil? ? nil : info.name
  end

  def youku_name
    info = current_user.youku_info
    info.nil? ? nil : info.name
  end

  def baidu_path
    BAIDU_CLIENT.auth_code.authorize_url(:redirect_uri => account_TP_callback_url('baidu'))
  end

  def youku_path
    YOUKU_CLIENT.auth_code.authorize_url(:redirect_uri => account_TP_callback_url('youku'))
  end

  def path_with_type(type)
    case type
      when 'baidu'
        baidu_path
      when 'youku'
        youku_path
    end
  end

  def third_party_js
    s = <<-script
$(document).ready(function(){
  $('.iframe').colorbox({
    iframe:true,
    width:'80%',
    height:'80%'
  });
  this.auth_over = function(value, type){
    $(value).replaceAll('#' + type);
    $.fn.colorbox.close();
  };
});
    script
    raw "<script type='text/javascript'>#{s}</script>"
  end

  def third_party_callback_js
    from = params[:from]
    case from
      when 'baidu'
        content = third_party_tag(baidu_yun_name, 'baidu', path_with_type(from))
      when 'youku'
        content = third_party_tag(youku_name, 'youku', path_with_type(from))
    end
    s = <<-script
$(document).ready(function(){
  setTimeout(function(){
    parent.document.auth_over(
    '#{j content}',
    '#{j from}'
    )
  },2000);
});
    script
    raw "<script type='text/javascript'>#{s}</script>"
  end
end
