ButtonSelecter = '.extend .extend-button'
ListSelecter = '.extend-list'
$(document).ready ->
  $(ButtonSelecter).click (event) ->
    $this = $(this);
    list = $this.parent('.extend').find(ListSelecter)
    list.slideDown()
    $this.children('.icon').removeClass('icon-plus-2').addClass('icon-minus-2')
    event.stopPropagation()
  $(document).click ->
    $(ListSelecter).slideUp()
    $(ButtonSelecter).children('.icon').removeClass('icon-minus-2').addClass('icon-plus-2')