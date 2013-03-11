__soran =
  init: (conn) ->
    this.conn = conn
    data =
      kind: 'bugsUserName'
      name: $('.username').find('strong').text()
    this.conn.postMessage data
    this

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

__soran.init chrome.extension.connect()

$('li.listRow').on 'click', (e) ->
  trackNumber = $(this).find('input[name=_isStream]').attr('value')
  __soran.getBugsTrackInfo trackNumber, (track) ->
    track.serviceName = 'bugs'
    track.id = trackNumber
    track.kind = 'bugsTrack'
    __soran.chromeConn.postMessage track
    __soran.conn.postMessage
  true