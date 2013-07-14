GroupSelector = '.tab-group'
Active = 'active'

$(document).delegate("#{GroupSelector} .btn", 'click', ->
  $this = $(this)
  return if $this.hasClass(Active)
  $group = $this.parent(GroupSelector)
  return if $group.length == 0
  $group.children('.btn').each ->
    if $(this).hasClass(Active)
      $(this).removeClass(Active)
      f = $(this).attr('for')
      $("##{f}").hide()
      $("##{f}").trigger('hide')
  $this.addClass('active')
  f = $this.attr('for')
  $("##{f}").show()
  $("##{f}").trigger('show')
)

