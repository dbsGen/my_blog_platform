module Account::NoticesHelper
  def notice_box_tag(notice)
    html = ''
    params = notice.params
    case notice.type
      when 'reply_comment'
        comment = Comment.first(:id => params[:comment_id])
        html << render(:partial => 'account/notices/reply', :locals => {
            :user => comment.creater,
            :comment => comment,
            :reply_to => comment.reply_to,
            :readed => notice.readed
        })
      when 'refer_comment'
        comment = Comment.first(:id => params[:comment_id])
        html << render(:partial => 'account/notices/comment', :locals => {
            :user => comment.creater,
            :comment => comment,
            :readed => notice.readed
        })
      when 'system'
        html << render(:partial => 'account/notices/system', :locals => {
            :content => params[:content],
            :title => params[:title]
        })
      when 'refer_article'
        article = Article.first(:id => params[:article_id])
        html << render(:partial => 'account/notices/article', :locals => {
            :user => article.creater,
            :article => article,
            :readed => notice.readed
        })
      when 'reply_article'
        comment = Comment.first(:id => params[:comment_id])
        html << render(:partial => 'account/notices/reply_article', :locals => {
            :user => comment.creater,
            :comment => comment,
            :readed => notice.readed
        })
      else
        html << render(:partial => 'account/notices/other'   , :locals => {
            :notice => notice,
            :readed => notice.readed
        })
    end
    notice.set :readed => true
    raw html
  end
end
