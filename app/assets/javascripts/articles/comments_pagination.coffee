@goPage = (that) ->
  $this = $(that)
  url = $this.attr('href')
  $.ajax(
    url: url
    success: (data) ->
      comments = $('.article-comments')
      comments.slideUp(->
        $('.article-comments').html(data)
        comments.slideDown()
      )
      $this.parents('.pagination').find('[disabled]').removeAttr('disabled')
      $this.attr('disabled', true)
    error: ->
      Messenger().post(
        type: 'error'
        message: '加载评论失败。'
      )
  )
  no