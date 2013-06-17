try
  Messenger.options = {
    extraClasses: 'messenger-fixed messenger-on-bottom messenger-on-right',
    theme: 'air'
  }
catch error
  alert "Get a error..\n#{error}"


@encrypt_password = (s) ->
  p = s
  for n in [1..5]
    p = sha256_digest p
  p

@show_error_information = (str) ->
  Messenger().post({
    message: str
    type: 'error'
  })

@show_information = (str) ->
  Messenger().post str