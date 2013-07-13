#= require vender/jquery.base64

@.follow = (id) ->
  $.ajax(
    url: "/followers/#{id}"
    type: 'post'
    headers: {
      "X-CSRF-Token":$('meta[name="csrf-token"]').attr('content')
    }
    data: {
      url: window.location.href.replace(/#.+$/,'')
    }
    success: (data) ->
      update(data)
    error: (request) ->
      Messenger().post(
        type: 'error'
        message: JSON.parse(request.responseText).msg
      )
  )
@.unfollow = (id) ->
  $.ajax(
    url: "/followers/#{id}"
    type: 'delete'
    headers: {
      "X-CSRF-Token":$('meta[name="csrf-token"]').attr('content')
    }
    data: {
      url: window.location.href.replace(/#.+$/,'')
    }
    success: (data) ->
      update(data)
    error: (request) ->
      Messenger().post(
        type: 'error'
        message: JSON.parse(request.responseText).msg
      )
  )
update = (data) ->
  data = JSON.parse(data)
  console.log data.replace
  all = $(data.selector)
  all.attr('mp-display', $.base64.decode data.replace)
  all.html(data.replaceName)
  $.MingP('reset')