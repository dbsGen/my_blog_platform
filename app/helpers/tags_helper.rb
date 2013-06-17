module TagsHelper
  def tags_tag(tags = nil)
    tags ||= @article.tags
    render partial: 'tags/tags', object: tags
  end
end
