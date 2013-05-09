###
  Author: Jinhyuk Lee
###

jQuery ->
  newsfeed = $('button#newsfeedButton')
  if newsfeed.length > 0
    newsfeed.click (e) ->
      $('#newsfeed').slideToggle()

  $('[data-toggle=tooltip]').tooltip()
  true
