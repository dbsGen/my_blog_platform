NewTagSelecter = '.new-tag'

$(document).ready ->
  $(NewTagSelecter).children('button').click ->
    $(NewTagSelecter).children('.new-tag-content').fadeIn()

  $('.new-tag .new-tag-content input').keypress (event) ->
    if event.keyCode == 27
      $('.new-tag .new-tag-content #close').click()

  $('.new-tag .new-tag-content #close').click ->
    $this = $(this)
    $this.parents('.new-tag-content').fadeOut()
  @removeTag = (that, article_id) ->
    $this = $(that)
    return if $this.attr('disabled')
    tag = $this.parent()
    label = tag.children('a.button').text()
    $this.attr('disabled', true)
    $.ajax(
      url: '/tags/' + label
      type: 'DELETE'
      data: {article_id: article_id}
      success: ->
        tag.remove()
      error: (r) ->
        msg = JSON.parse(r.responseText).msg || '删除失败'
        Messenger().post(
          type: 'error'
          message: msg
        )
        $this.removeAttr('disabled')
    )
