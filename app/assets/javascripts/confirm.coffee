@button_click = (that) ->
  $this = $(that)
  url = $this.attr('href')
  $this.attr('disabled', true)
  $.ajax(
    url: url
    complete: ->
      $this.removeAttr('disabled')
    success: (d) ->
      data = JSON.parse(d)
      Messenger().post(data.msg)
    error: (r) ->
      data = JSON.parse(r.responseText)
      Messenger().post(
        type: 'error'
        message: data.msg
      )
  )