# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#= require sha256
#= require third_party/show_authorize
#= require vender/jquery.colorbox-min

$(document).ready ->
  $('#modify-password-button').click ->
    $('#password-modal #loading-button').button('reset')
#    重置输入框
    $('#old_password').val('')
    $('#old_password').parents('div.control-group').removeClass('error')
    $('#new_password').val('')
    $('#new_password').parents('div.control-group').removeClass('error')
    $('#password_confirmation').val('')
    $('#password_confirmation').parents('div.control-group').removeClass('error')
  $('#password-modal #loading-button').click ->
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

    btn = $(this)
    btn.button 'loading'
    #开始请求
    request = $.ajax {
      url: "#{user_path}.json"
      type: 'PUT'
      data: {
        old_password: encrypt_password($('#old_password').val())
        new_password: encrypt_password($('#new_password').val())
      }
      success: (data) ->
        $('#password-modal #loading-button').button('reset')
        $('#password-modal').modal('hide')
        show_information data.msg
      error: (request, code, error) ->
        response = eval("(#{request.responseText})")
        $('#password-modal #loading-button').button('reset')
        $('#old_password').val('')
        $('#new_password').val('')
        show_error_information response.msg
    }

  $('#summary-area').change ->
    icon = $('#loading-icon')
    icon.removeClass('icon-ok icon-remove').addClass('spin icon-refresh')
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

  $('#nickname-text').change ->
    icon = $('#loading-icon2')
    icon.removeClass('icon-ok icon-remove').addClass('spin icon-refresh')
    icon.fadeIn()
    rmi = ->
      icon.fadeOut()
    request = $.ajax {
      url: "#{user_path}.json"
      type: 'PUT'
      data: {
        nickname: $('#nickname-text').val()
      }
      success: (data) ->
        icon.removeClass('spin icon-refresh').addClass('icon-ok')
        div = $('#nickname')
        div.html("<strong>#{$('#nickname-text').val()}</strong>")
        setTimeout(rmi, 1500)
      error: (request, code, error) ->
        icon.removeClass('spin icon-refresh').addClass('icon-remove')
        setTimeout(rmi, 1500)
    }

  $('#domain-button').click ->
    $('#domain-modal #loading-button').button('reset')
  $('#domain-modal #loading-button').click ->
    $('#domain-modal #loading-button').button('loading')
    $.ajax(
      url: "#{host_domain_path}.json"
      type: 'POST'
      data: {
        subdomain: $('#host_domain').val()
      }
      complete: ->
        $('#domain-modal #loading-button').button('reset')
      success: (data) ->
        data = JSON.parse(data)
        $('#domain-modal').modal('hide')
        $('#domain-control').html(data.msg)
      error: (r) ->
        data = JSON.parse(r.responseText)
        Messenger().post(
          type: 'error'
          message: data.msg
        )
    )
