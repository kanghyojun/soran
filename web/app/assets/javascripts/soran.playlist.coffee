owner = $("#listen").data('owner')

if owner isnt null
  window.soran.initPlaylist(owner)

$("#listen thead tr td").on "click", (e) ->
  window.soran.showPlayList $(this).attr("id").split("-")[1]
