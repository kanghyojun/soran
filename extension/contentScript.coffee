__soran = 
  getBugsTrackInfo: (trackNum, callback) ->
    that = this
    options =
      url: "http://music.bugs.co.kr/player/track/#{ trackNum }"
      success: (data) ->
        callback that.track(data.track.artist_nm, data.track.album_artist_nm, data.track.album_title, data.track.track_title, data.track.genre_dtl, data.track.len, data.track.release_ymd)
      error: (jqXHR, textStatus, errorThrow) ->
        callback undefined

    $.ajax options

  track: (artist, albumArtist, albumTitle, title, genre, length, releaseDate) ->
    data =
      artist: artist
      albumArtist: albumArtist
      albumTitle: albumTitle
      title: title
      genre: genre
      length: length
      releaseDate: releaseDate

    data

__soran.chromeConn = chrome.extension.connect()

# Bugs configuration
$('li.listRow').on 'click', (e) ->
  trackNumber = $(this).find('input[name=_isStream]').attr('value')
  __soran.getBugsTrackInfo trackNumber, (track) ->
    console.log track
    __soran.chromeConn.postMessage track
  true
