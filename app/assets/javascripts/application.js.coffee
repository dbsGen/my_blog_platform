# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# the compiled file.
#
# WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
# GO AFTER THE REQUIRES BELOW.
#
#= require jquery
#= require jquery_ujs
#= require bootstrap.min
#= require underscore-1.4.4
#= require backbone-0.9.10
#= require messenger
#= require messenger-theme-future
#= require tools/autoExec
#= require third_party/jquery_extend
#= require tools/tab


try
  Messenger.options = {
  extraClasses: 'messenger-fixed messenger-on-bottom messenger-on-right',
  theme: 'air'
  }
catch error
  alert "Get a error..\n#{error}"


$(document).ready ->
  set_footer()

$(window).resize ->
  set_footer()

set_footer = ->
  if $(window).height() >= $(document).height()
    $('#footer').addClass('navbar-fixed-bottom')
  else
    $('#footer').removeClass('navbar-fixed-bottom')

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


