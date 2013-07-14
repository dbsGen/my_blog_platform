# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#= require search
#= require tools/ajaxQueue

ActiveClass = 'active'

$(document).ready ->
  $('#recommend').click ->
    $this = $(this)
    if $this.hasClass(ActiveClass)
      $this.removeClass(ActiveClass)
      $('[for="recommend-content"]').hide()
      $('#recommend-content').hide()
      $('[for="content"]').show()
      $('#content').show()
      $('#recommend-content-result').hide()
      $('#content-result').hide()
    else
      $this.addClass(ActiveClass)
      $('[for="content"]').hide()
      $('#content').hide()
      $('#recommend-content-result').hide()
      $('#content-result').hide()
      rc = $('#recommend-content')
      rs = $('[for="recommend-content"]')
      rc.show()
      rs.show()
      if rc.html().trim() == ''
        $.ajax(
          url: rs.attr('search-url')
          success: (data) ->
            rc.html(data)
          error: ->
            Messenger().post(
              type: 'error'
              message: '获取推荐失败！'
            )
        )