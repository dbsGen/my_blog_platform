# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#= require sha256
#= require rails.validations
#= require rails.validations.custom

$(document).ready ->
  $('#new_user').submit ->
    try
      return on_create_user()
    catch error
      alert "Get a error.. \n#{error}"
      no

on_create_user = ->
  p = $('#user_password').val()
  p = encrypt_password p
  $('#user_password').val(p)
  yes
