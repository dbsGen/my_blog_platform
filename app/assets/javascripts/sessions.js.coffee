# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#= require sha256

$(document).ready ->
  $('#login_form').submit ->
    try
      return login_submit()
    catch error
      alert "Get a error... \n#{error}"
      no

login_submit = ->
  if !($('#user_name').val().length >= 4)
    Messenger().post
      message: '帐号必须不少于4个字符!'
      type: 'error'
      showCloseButton: true
    return no
  if !($('#user_password').val().length in [6..14])
    Messenger().post
      message: '密码必须是4-16字符!'
      type: 'error'
      showCloseButton: true
    return no
  p = $('#user_password').val()
  p = encrypt_password p
  $('#user_password').val(p)
  yes