module Account::ThirdPartiesHelper
  def third_party_tag(value, type, path = nil)
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

  def mingp_name
    info = current_user.mingp_info
    info.nil? ? nil : info.name
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
      else
        content =''
    end
    s = <<-script
$(document).ready(function(){
  setTimeout(function(){
    parent.auth_over(
    '#{j content}',
    '#{j from}'
    )
  },2000);
});
    script
    raw "<script type='text/javascript'>#{s}</script>"
  end

  def tp_files_tag(file, tp_id)
    file_name = file['path'][/[^\/]+$/]
    ext = file_name[/[^\.]+$/]
    case ext
      when 'jpg', 'png'
        src = '/assets/photo.png'
      else
        src = '/assets/document.png'
    end
    sub_path = file['path'].gsub BAIDU_ROOT_FOLDER, ''
    html = <<-html
<a class='thumbnail' onclick='console.log(select_file);select_file(this)' title='#{file_name}' data-tp-id='#{tp_id}' data-path='#{sub_path}'>
  <img src='#{src}' class='baidu_pic' data-tp-id='#{tp_id}' data-path='#{sub_path}'></img>
  <div class='caption'>#{file_name}</div>
</a>
    html
    raw html
  end
end
