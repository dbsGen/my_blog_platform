class CommentsController < ApplicationController
  before_filter :require_login, :only => [:create]

  def create
    article = Article.first(:id => params[:article])
    return render_404 if article.nil?
    reply_to = Comment.first(:id => params[:reply_to])

    elements = params[:elements]
    es = []
    s = elements.size
    notice_to = {}
    s.times do |i|
      d = elements[i.to_s]
      e = Element.create_with_params(d) do |user|
        notice_to[user.name] = user
      end
      es << e
    end

    comment = Comment.new(
        :created_at => Time.now,
        :creater => current_user,
        :article => article,
        :reply_to => reply_to,
        :elements => es,
        :flood => article.comments.count + 1
    )

    if comment.save
      notice_to.each do |_, v|
        Notice.add_notice_from_refer_comment(v, comment)
      end
      if reply_to.nil?
        Notice.add_notice_from_reply_article(article.creater, comment)
      else
        Notice.add_notice_from_reply_comment(reply_to.creater, comment)
      end
      @comment = comment
      respond_to do |format|
        format.js
        format.html {render_format 200, t('comments.send.success')}
      end
    else
      render_format 500, t('comments.send.failed')
    end
  rescue Exception => e
    render_format 500, e.to_s
  end
end
