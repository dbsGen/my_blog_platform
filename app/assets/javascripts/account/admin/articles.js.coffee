# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#= require search
#= require tools/ajaxQueue

ActiveClass = 'active'

$(document).ready ->
  $('#recommend').click ->
    $this = $(this)
    $this.attr('disabled', true)
    if $this.hasClass(ActiveClass)
      $this.removeClass(ActiveClass)
      window.source_url = window.all_url
      window.search_path = window.all_search_path
      $.ajax_q(
        url: "#{window.all_url}.js"
        success: (data) ->
          eval(data)
        complete: ->
          $this.removeAttr('disabled')
      )
    else
      $this.addClass(ActiveClass)
      window.source_url = window.recommend_url
      window.search_path = window.recommend_search_path
      $.ajax_q(
        url: "#{window.recommend_url}.js"
        success: (data) ->
          eval(data)
        complete: ->
          $this.removeAttr('disabled')
      )