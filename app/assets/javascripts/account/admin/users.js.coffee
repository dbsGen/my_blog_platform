# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/



$(document).ready ->
  $('#search-text').focus ->
    $('#search-icon').removeClass('disable').addClass('touch-able')
  $('#search-text').blur ->
    $('#search-icon').removeClass('touch-able').addClass('disable')
  $('#search-icon').click ->
#    删除里面的数据
    if $(this).hasClass('icon-remove-circle')
      $('#search-text').val('')
      $('#search-icon').removeClass('icon-remove-circle').addClass('icon-search')

  $('#search-text').keyup (e) ->
    if e.which == 13
      #开始搜索
      if ($('#search-text').val().length == 0)
        restore()
        return
      search($(this).val())
    else if e.which == 27
      clean()
    else
      #检查改变
      if e.currentTarget.value.length != 0
        $('#search-icon').removeClass('icon-search').addClass('icon-remove-circle')
      else
        $('#search-icon').removeClass('icon-remove-circle').addClass('icon-search')

clean = ->
  $('#search-text').val('')
  $('#search-icon').removeClass('icon-remove-circle').addClass('icon-search')
  $('#search-text').blur()
  restore()

restore = ->
  over = ->
    $('#search-icon').removeClass('spin icon-refresh').addClass('icon-search')
    $(document).loading = false
  $(document).loading = true
  $('#search-icon').removeClass('icon-search icon-remove-circle').addClass('spin icon-refresh')
  $.getScript(@source_url, over)

search = (key) ->
  return if $(document).loading == true
  success = (data)->
    $(document).loading = false
    eval(data)
    $('#search-icon').removeClass('spin icon-refresh').addClass('icon-remove-circle')
  error = (request, code, error) ->
    Messenger().post({
      message: error
      type:'error'
    })
    $('#search-icon').removeClass('spin icon-refresh').addClass('icon-remove-circle')
    $(document).loading = false
  $.ajax({
         type: 'POST'
         url: "#{account_admin_search_users_path}.js"
         data: {
         key: key
         }
         success: success
         error:error
  })
  $(document).loading = true
  $('#search-icon').removeClass('icon-search icon-remove-circle').addClass('spin icon-refresh')



