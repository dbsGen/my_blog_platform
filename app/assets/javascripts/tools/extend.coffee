ButtonSelecter = '.extend .extend-button'
ListSelecter = '.extend-list'
$(document).ready ->
  $(ButtonSelecter).click (event) ->
    $this = $(this);
    list = $this.parent('.extend').find(ListSelecter)
    icon = $this.children('.icon')
    if icon.hasClass('icon-plus-2')
      list.slideDown()
      icon.removeClass('icon-plus-2').addClass('icon-minus-2')
      event.stopPropagation()
    else
      icon.removeClass('icon-minus-2').addClass('icon-plus-2')
  $(document).click ->
    $(ListSelecter).slideUp()
    $(ButtonSelecter).children('.icon').removeClass('icon-minus-2').addClass('icon-plus-2')