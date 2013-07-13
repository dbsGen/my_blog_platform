module Account::NoticesHelper
  def notice_box_tag(notice)
    html = ''
    params = notice.params
    case notice.type
      when 'reply_comment'
        comment = Comment.where(id:params['comment_id']).first
        html << render(:partial => 'account/notices/notice/reply', :locals => {
            :user => comment.creater,
            :comment => comment,
            :reply_to => comment.reply_to,
            :readed => notice.readed
        })
      when 'refer_comment'
        comment = Comment.where(id:params['comment_id']).first
        html << render(:partial => 'account/notices/notice/comment', :locals => {
            :user => comment.creater,
            :comment => comment,
            :readed => notice.readed
        })
      when 'system'
        html << render(:partial => 'account/notices/notice/system', :locals => {
            :content => params[:content],
            :title => params[:title]
        })
      when 'refer_article'
        article = Article.where(id:params['article_id']).first
        html << render(:partial => 'account/notices/notice/article', :locals => {
            :user => article.creater,
            :article => article,
            :readed => notice.readed
        })
      when 'reply_article'
        comment = Comment.where(:id =>params['comment_id']).first
        html << render(:partial => 'account/notices/notice/reply_article', :locals => {
            :user => comment.creater,
            :comment => comment,
            :readed => notice.readed
        })
      when 'like_person'
        user = User.find(params['user_id'])
        html << render(:partial => 'account/notices/notice/like_person', :locals => {
            :user => user,
            :readed => notice.readed
        })
      else
        html << render(:partial => 'account/notices/notice/other'   , :locals => {
            :notice => notice,
            :readed => notice.readed
        })
    end
    unless notice.readed
      expire_fragment_(notice)
      notice.readed = true
      notice.save!
    end
    raw html
  rescue StandardError => _
    ''
  end
end
