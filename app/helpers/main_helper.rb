module MainHelper
  def auto_pagination_tag2(url)
    html = ''
    html << javascript_include_tag('vender/scrollpagination_myboka')
    scr = <<-script
$(function(){
    document.last = $('[pagination-key]').last().attr('pagination-key');
    console.log(document.last);
    $('#content-field').scrollPagination({
        'contentPage': '#{url}',
        'contentData': {
            last: document.last
        },
        'scrollTarget': $(window),
        'heightOffset': 10,
        'beforeLoad': function(){
            $('#content-tail').fadeIn();
        },
        'afterLoad': function(elementsLoaded){
             if (elementsLoaded.length == 0) {
                  $('#content-tail').html('#{t('pagination.over')}');
                  $('#content-field').stopScrollPagination();
             }else {
                  $(elementsLoaded).fadeInWithDelay();
                  $('#content-tail').fadeOut();
                  document.last = elementsLoaded.filter('[pagination-key]').last().attr('pagination-key');
             }
        }
    });

    // code for fade in element by element
    $.fn.fadeInWithDelay = function(){
        var delay = 0;
        return this.each(function(){
            $(this).delay(delay).animate({opacity:1}, 200);
            delay += 100;
        });
    };

});
    script
    html << (javascript_tag() { raw scr })
    raw html
  end

  def home_title_tag(article)
    html = '<div>'
    html << link_to(article.title, article_path(article), :class => 'article-title')
    user = article.creater
    #TODO 需要补全url
    html << "<span class='article-subtitle'> by:#{name_tag(user)}</span>"
    html << '</div>'
    raw html
  end

  def home_summary_tag(article)
    raw "<div class='content'>#{article.summary do |content|
      text_clip content
    end
    }</div>"
  end

  def text_clip(content, limit = 250)
    content = replace_tp_tag(content)
    doc = Nokogiri::HTML(content)
    images = ''
    doc.css('img').each do |img|
      images << img.to_s
    end
    c = strip_tags(content)
    text = c.length > limit ? "#{c[0..limit]}..." : c
    "#{text.nil? or text.length == 0 ? '' : "#{text} <br/>"} #{images}"
  end

  def new_notice_tag
    html = "<div id='notice-count' style='display:none'><a href='#{account_notices_path}'><span id='notice-badge' class='badge badge-important'></span></a></div>"
    html << javascript_tag do
      raw <<-script
function start_count(){
  $.ajax({
    url:'#{account_unread_count_path('json')}',
    success: function(data){
      data = eval("("+ data +")")
      if (data.count > 0) {
        $('#notice-count').fadeIn();
        $('#notice-count').children('.badge').text(data.count);
      }else {
        $('#notice-count').fadeOut();
        $('#notice-count').children('.badge').text(data.count);
      }
    }
  });
}
start_count();
setInterval('start_count()',30000);
      script
    end
    raw html
  end

  def avatar_url(user, exp = nil)
    if user.nil?
      email = 'none'
    else
      email = user.is_a?(User) ? user.email : user
    end
    h = {email: email}
    h[:expression] = exp unless exp.nil?
    "#{CONFIG['carte_site']}public/avatar?#{URI.encode_www_form(h)}"
  end

  def name_tag(user)
    return '没有这个用户' if user.nil?
    if current_user.nil?
      h = nil
      name = user.nickname
    else
      h = escape_once follow_button(user)
      name = name_with_heart(user)
    end
    link_to(name, '#', 'mp-email' => user.email, 'mp-display' => h)
  end

  def follow_button(user, url = nil)
    f = current_user.follow?(user) ? 'unfollow' : 'follow'
    raw "<button style='background:none;border:none;' onclick='parent.location=\"#{url||request.url}#method:#{f}(\\\"#{user.id}\\\")\"'><img height='13px' src='http://#{request.host}/images/#{f}.png'></button>"
  end

  def name_with_heart(user)
    current_user.follow?(user) ? raw("#{user.nickname}<span class='icon-heart' style='color:red'></span>") : user.nickname
  end

  def avatar_tag(user)
  end

  def render_content
    render file: @content_path
  end

  def bk_javascript_include_tag(*sources)
    insert_static_url sources
    javascript_include_tag *sources
  end

  def bk_stylesheet_link_tag(*sources)
    insert_static_url sources
    stylesheet_link_tag *sources
  end

  def insert_static_url(*sources)
    url = sources.first.shift
    url = "#{CONFIG['static_temp_site']}/#{url}" if url[/^\w+:\/\//].nil?
    sources.first.unshift url
    sources
  end

  def template_path(path)
    "#{@template.dynamic_path}/#{path}"
  end

  def render_object(path, header, object)
    h = {:locals => {:header => header, :object => object}}
    if path[/^\//].nil?
      h[:partial] = path
    else
      h[:file] = path
    end

    render h
  end
end
