# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

SearchAttr = 'search-url'

search_collection = (t) ->
  $this = if (t instanceof jQuery) then t else $(t)
  return $this if $this.attr(SearchAttr)
  $this.parents("[#{SearchAttr}]")

text_tag = (t) ->
  search_collection(t).find('#search-text')

action_tag = (t) ->
  search_collection(t).find('#search-icon')

search_content = (t_name) ->
  $source = $("##{t_name}")
  return if $source.length == 0
  $content = $("##{t_name}-result")
  if $content.length == 0
    $content = $("<div id='#{t_name}-result' style='display: none'></div>")
    $content.insertAfter($source)
  $content

$(document).delegate("[#{SearchAttr}] #search-text", 'focus', ->
  action_tag(this).removeClass('disable').addClass('touch-able')
)
$(document).delegate("[#{SearchAttr}] #search-text", 'blur', ->
  action_tag(this).removeClass('touch-able').addClass('disable')
)
$(document).delegate("[#{SearchAttr}] #search-icon", 'click', ->
  if $(this).hasClass('icon-remove-circle')
    text_tag(this).val('')
    action_tag(this).removeClass('icon-remove-circle').addClass('icon-search')
    so = search_collection(this).data('search')
    so.clean() if so
)
$(document).delegate("[#{SearchAttr}] #search-text", 'keyup', (e) ->
  $search = search_collection(this)
  search_object = $search.data('search')
  unless search_object
    search_object = new Search($search[0])
    $search.data('search', search_object)
  if e.which == 13
    #开始搜索
    if ($(this).val().length == 0)
      search_object.restore()
      return
    search_object.search()
  else if e.which == 27
    search_object.clean()
  else
    #检查改变
    if e.currentTarget.value.length != 0
      action_tag($search).removeClass('icon-search').addClass('icon-remove-circle')
    else
      action_tag($search).removeClass('icon-remove-circle').addClass('icon-search')
)

$.fn.search = (commend) ->
  s = $(this).data('search')
  return unless s
  switch commend
    when 'start'
      s.search()
    when 'clean'
      s.clean()
    else

class Search
  constructor: (@s_object) ->

  clean: ->
    text = text_tag(@s_object)
    text.val('')
    action_tag(@s_object).removeClass('icon-remove-circle').addClass('icon-search')
    text.blur()
    @restore()

  restore: ->
    source = $(@s_object).attr('for')
    $content = search_content(source)
    $("##{source}").css('display', 'block')
    $content.css('display', 'none')

  search: ->
    return if @loading == true
    action = action_tag(@s_object)
    that = this
    success = (data)->
      that.loading = false
      source = $(that.s_object).attr('for')
      $content = search_content(source)
      $content.html(data)
      $("##{source}").css('display', 'none')
      $content.css('display', 'block')
      action.removeClass('spin icon-refresh').addClass('icon-remove-circle')
    error = (request, code, error) ->
      Messenger().post({
        message: error
        type:'error'
      })
      action.removeClass('spin icon-refresh').addClass('icon-remove-circle')
      that.loading = false

    @loading = true
    action.removeClass('icon-search icon-remove-circle').addClass('spin icon-refresh')
    $.ajax({
      type: 'GET'
      url: $(@s_object).attr(SearchAttr)
      data: {
        key: text_tag(@s_object).val()
      }
      success: success
      error:error
    })