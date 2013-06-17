class ElementCommentController < ApplicationController
  before_filter :require_login, only: [:create, :destroy]

  def create
    ch = params[:comment]
    ch[:created_at] = Time.now
    ch[:user] = current_user
    comment = ElementComment.new(ch)
    if comment.save
      render_format 200, '评论成功'
    else
      render_format 500, '评论失败'
    end
  end

  def destroy
    comment = ElementComment.find_by_id(params[:id])
    if comment.user == current_user
      comment.destroy
      render_format 200, '删除成功'
    else
      render_format 403, '删除失败'
    end
  end

  def index
    comments = ElementComment.where(element_id: params[:element_id])
    cs = []
    comments.each do |c|
      cs << c.to_hash(only: [:element_id, :content, :created_at])
    end
    render json: {comments: cs}
  end
end
