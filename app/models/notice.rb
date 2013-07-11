class Notice
  include Mongoid::Document

  field :type, type: String
  #数据
  field :params, type: Hash
  #已读
  field :readed, type: Boolean, :default => false
  #创建时间
  field :created_at, type: Time

  embedded_in :user

  index 'created_at' => 1

  #type:
  # system 系统消息
  # comment 评论中提到
  # reply 回复了你
  # article 文章中提到了你
  validates :type, :params, :created_at, :presence => true
  validates :type, :inclusion => %w(system refer_comment reply_comment refer_article reply_article)

  def self.add_notice_from_refer_comment(user, comment)
    params = {
        :comment_id => comment.id
    }
    create_notice(user, params, 'refer_comment')
  end

  def self.add_notice_from_reply_comment(user, comment)
    params = {
        :comment_id => comment.id
    }
    create_notice(user, params, 'reply_comment')
  end

  def self.add_notice_from_reply_article(user, comment)
    params = {
        :comment_id => comment.id
    }
    create_notice(user, params, 'reply_article')
  end

  def self.add_notice_from_refer_article(user, article)
    params = {
        :article_id => article.id
    }
    create_notice(user, params, 'refer_article')
  end

  def self.add_notice_from_system(title, content)
    params = {
        :title => title,
        :content => content
    }
    create_notice(user, params, 'system')
  end

  def self.create_notice(user, params, type)
    notice = Notice.new(
        :type => type,
        :params => params,
        :created_at => Time.now,
        :user => user
    )
    notice.save
  end
end
