module MainHelper
  def auto_pagination_tag(url)
    html = ''
    html << javascript_include_tag('scrollpagination')
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
    html << "<span class='article-subtitle'> by:#{link_to(user.name, '#')}</span>"
    html << '</div>'
    raw html
  end

  def home_summary_tag(article)
    begin
      fe = article.elements.first
    rescue Exception => e
      logger.error "Can not get the first element, #{e}"
      return ''
    end
    c = strip_tags fe.content
    raw "<div class='article-summary'>#{c.length > 250 ? "#{c[0..250]}..." : c}</div>"
  end
end
