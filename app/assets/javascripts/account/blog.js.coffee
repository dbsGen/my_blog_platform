# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
  $('#add-page').click ->
    $this = $(this)
    page = $this.children('.page').clone()
    page.insertBefore($this)
    page.css 'display', 'block'
  $('#check-button').click ->
    form = $('#edit-form')
    form.attr('target', 'shower')
    form.attr('action', $(this).attr('href'))
    form.submit()
  $('#submit-button').click ->
    form = $('#edit-form')
    form.removeAttr('target')
    form.attr('action', $(this).attr('href'))
    form.submit()