module CommentsHelper
  def simple_comment_tag(comment, reply_count = 0)
    @comments_index["#{comment.id}"] = true
    render(
        :partial => 'comments/comment',
        :locals => {
            :reply_to => comment.reply_to,
            :comment => comment,
            :author => comment.creater,
            :reply_count => reply_count
        }
    )
  end

  def render_comment(comment, reply_count = 0)
    html = ''
    @comments_index ||= {}

    html << "<div class='comment-box'>"
    html << simple_comment_tag(comment, reply_count)
    html << '</div>'

    raw html
  end

  def reply_tag(comment)
    html = '['
    html << link_to(t('comments.reply'), '#article-replay',
                    :onclick => "reply('#{comment.id}', #{comment.flood || 0})")
    html << ']'
    raw html
  end

  def add_quote(element)
    content = element.content
    quote_info = element.quote_info
    nc = String.new(content)
    content.scan(ID_REGEXP) do |match|
      name = match[1..-1]
      id = quote_info[name]
      unless id.nil?
        #这里需要补全地址
        html = link_to(match, '#')
        nc.sub!(match, html)
      end
    end
    nc
  end
end
