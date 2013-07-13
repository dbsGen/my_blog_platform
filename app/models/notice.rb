class Notice
  include Mongoid::Document

  field :type, type: String
  #数据
  field :params, type: Hash
  #已读
  field :readed, type: Boolean, :default => false
  #用于搜索用
  field :key, type: String
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
  validates :type, :inclusion => %w(system refer_comment reply_comment refer_article reply_article like_person)

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

  def self.add_notice_from_system(user, title, content)
    params = {
        :title => title,
        :content => content
    }
    create_notice(user, params, 'system')
  end

  def self.add_like_from_user(liked_user, like_user)
    return nil if liked_user.notices.check_for_key(like_user.id.to_s)
    params = {
        user_id: like_user.id
    }
    create_notice(liked_user, params, 'like_person', like_user.id.to_s)
  end

  def self.create_notice(user, params, type, key = nil)
    notice = Notice.new(
        :type => type,
        :params => params,
        :created_at => Time.now,
        :user => user,
        :key => key
    )
    notice.save!
  end
end
