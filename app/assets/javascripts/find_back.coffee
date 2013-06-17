@formSubmit = (that) ->
  $this = $(that)
  name = $('#user_name').val()
  if name.length < 4
    Messenger().post(
      type: 'error'
      message: '用户名或邮箱过短。'
    )
    return no
  $this.attr('disabled', true)
  $.ajax(
    url: $this.attr('href')
    type: 'post'
    data: {
      user_name: name
    }
    success: (data) ->
      eval(data)
    error: ->
      Messenger().post(
        type: 'error'
        message: '网路错误'
      )
      $this.removeAttr('disabled')
  )
  yes