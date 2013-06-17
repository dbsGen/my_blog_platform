#= require sha256

@formSubmit = (that, token) ->
  $this = $(that)
  pwd = $('#password').val()
  pwd_c = $('#password_confirmation').val()
  if pwd.length < 4
    Messenger().post(message:'密码必须大于4位', type: 'error')
    return no
  if pwd != pwd_c
    Messenger().post(message:'两次输入不一致，请检查!', type: 'error')
    return no
  $this.attr('disabled', true)
  $.ajax(
    url: $this.attr('href')
    type: 'post'
    data: {
      token: token
      password: encrypt_password(pwd)
    }
    success: (data) ->
      eval(data)
    error: ->
      $this.removeAttr('disabled')
  )
  yes

