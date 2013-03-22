$(document).ready ->
  $('#post').click ->
    btn = $(this)
    btn.button('loading')
    $.ajax(
      url: btn.attr('href')
      type: 'post'
      data: {
        title: $('#title').val()
        content: $('#content_id').val()
      }
      complete: ->
        btn.button('reset')
    )
    no