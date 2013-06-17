$(document).ready ->
  $tags = $('#tags')
  src = $tags.attr('src')
  $.ajax(
    url: src
    success: (data) ->
      $tags.html(data)
  )