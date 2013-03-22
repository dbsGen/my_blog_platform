# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#= require sha256

$(document).ready ->
  $('#modify-password-button').click ->
    $('#loading-button').button('reset')
#    重置输入框
    $('#old_password').val('')
    $('#old_password').parents('div.control-group').removeClass('error')
    $('#new_password').val('')
    $('#new_password').parents('div.control-group').removeClass('error')
    $('#password_confirmation').val('')
    $('#password_confirmation').parents('div.control-group').removeClass('error')
  $('#loading-button').click ->
    op = $('#old_password').val()
    np = $('#new_password').val()
    cp = $('#password_confirmation').val()
    if op.length < 6
      $('#old_password').parents('div.control-group').addClass('error')
      show_error_information short_password
      return
    else
      $('#old_password').parents('div.control-group').removeClass('error')

    if np.length < 6
      $('#new_password').parents('div.control-group').addClass('error')
      show_error_information short_password
      return
    else
      $('#new_password').parents('div.control-group').removeClass('error')

    if np != cp
      $('#password_confirmation').parents('div.control-group').addClass('error')
      show_error_information confirmation_failed
      return
    else
      $('#password_confirmation').parents('div.control-group').removeClass('error')

    $(this).button 'loading'
    #开始请求
    request = $.ajax {
      url: "#{user_path}.json"
      type: 'PUT'
      data: {
        old_password: encrypt_password($('#old_password').val())
        new_password: encrypt_password($('#new_password').val())
      }
      success: (data) ->
        $('#loading-button').button('reset')
        $('#password-modal').modal('hide')
        show_information data.msg
      error: (request, code, error) ->
        response = eval("(#{request.responseText})")
        $('#loading-button').button('reset')
        $('#old_password').val('')
        $('#new_password').val('')
        show_error_information response.msg
    }

  $('#summary-area').change ->
    icon = $('#loading-icon')
    icon.fadeIn()
    rmi = ->
      icon.fadeOut()
    request = $.ajax {
      url: "#{user_path}.json"
      type: 'PUT'
      data: {
      summary: $('#summary-area').val()
      }
      success: (data) ->
        icon.removeClass('spin icon-refresh').addClass('icon-ok')
        div = $('#summary')
        div.html("<small>#{$('#summary-area').val()}</small>")
        setTimeout(rmi, 1500)
      error: (request, code, error) ->
        icon.removeClass('spin icon-refresh').addClass('icon-remove')
        setTimeout(rmi, 1500)
    }