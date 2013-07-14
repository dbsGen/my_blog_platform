# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).delegate('#follow-button', 'click', ->
  $this = $(this)
  $this.attr('disabled', true)
  method = $this.attr('method').toLowerCase()
  $.ajax(
    url: $this.attr('href')
    type: method
    complete: ->
      $this.removeAttr('disabled')
    success: ->
      if method == 'delete'
        $this.attr('method', 'post')
        $this.text('关注')
      else if method == 'post'
        $this.attr('method', 'delete')
        $this.text('取消关注')
    error: ->
      Messenger().post(
        type: 'error'
        message: '操作失败'
      )
  )
)

$(document).delegate('#following', 'show', ->
  initialize(this)
)

$(document).delegate('#followers', 'show', ->
  initialize(this)
)

$(document).ready ->
  initialize(document.getElementById('following'))

initialize = (that) ->
  $this = $(that)
  if $this.html().trim() == ''
    $search = $("[for='#{$this.attr('id')}'][search-url]")
    $.ajax(
      url: $search.attr('search-url')
      success: (data) ->
        $this.html(data)
    )