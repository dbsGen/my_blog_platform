#= require tools/ajaxQueue

Input_Selecter = '.search input'
Helper_Selecter = '.search button.helper'
Content_Selecter = '.result .search-content'
Result_Selecter = '.result'
Baidu_Selecter = '.search .baidu'
Google_Selecter = '.search .google'
Hidden_Class = 'hidden'
Active_Class = 'active'
Url_Attr = 'data-url'

check_helper = (helper) ->
  $input = helper.parent().children(Input_Selecter)
  if $input.val().length > 0
    helper.removeClass(Hidden_Class)
  else
    helper.addClass(Hidden_Class)
  if $.ajax_loading()
    helper.addClass(Active_Class)
  else
    helper.removeClass(Active_Class)

stop_request = (search) ->
  $.ajax_stop()
  $input = search.children(Input_Selecter)
  $input.val('')
  $helper = search.children(Helper_Selecter)
  search.children(Result_Selecter).slideUp()
  check_helper($helper)

$(document).ready ->
  $(Input_Selecter).keyup (event) ->
    $this = $(this)
    $search = $this.parent()
    if  event.which == 27
      stop_request($search)
    else
      $helper = $search.children(Helper_Selecter)
      val = $this.val()
      if val.length > 0
        $.ajax_stop()
        $.ajax_q(
          url: $this.attr(Url_Attr)
          data: {
            key: $this.val()
          }
          complete: ->
            $helper.removeClass(Active_Class)
          success: (data) ->
            $search.find(Content_Selecter).html(data)
            $search.children(Result_Selecter).slideDown()
        )
      else
        stop_request($search)
      check_helper($helper)
  $(Baidu_Selecter).click ->
    $search = $(this).parents('.search')
    $input = $search.children(Input_Selecter)
    window.open("http://www.baidu.com/s?wd=#{$input.val()}+site:#{$(this).attr(Url_Attr)}")
  $(Google_Selecter).click ->
    $search = $(this).parents('.search')
    $input = $search.children(Input_Selecter)
    window.open("http://www.google.com.hk/search?sitesearch=#{$(this).attr(Url_Attr)}&as_q=#{$input.val()}")

  $(Helper_Selecter).click ->
    stop_request($(this).parent())
