$(document).ready ->
  $(document).delegate('[data-remote]','ajax:success', (_, data) ->
    eval(data)
  )
  $(document).delegate('[data-remote]','ajax:error', (_,request) ->
    data = JSON.parse(request.responseText)
    Messenger().post(
      type: 'error'
      message: data.msg
    )
  )