__soran =
  BUGS_PREFIX: 'bugs'
  NAVER_PREFIX: 'naverMusic'  
  TRACK_POSTFIX: "Track"
  EVENT_USER_INIT: 'userInit'
  EVENT_LISTEN: 'listen'
  BUGS_TRACK_API_URL: "http://music.bugs.co.kr/player/track/"
  BUGS_DOMAIN: 'bugs.co.kr'
  ERROR: 'Error'
  servicePrefix: ''
  isListen: false
  conn: undefined
  loggedAt: 80
  nowPlaying:
    id: ''
    len: 0

  getBugsTrackInfo: (n, callback) ->
    console.log 'getBugsTrackInfo'
    that = this
    trackIdentifier = this.BUGS_PREFIX + "-" + n
    options =
      type: 'GET'
      url: this.BUGS_TRACK_API_URL + n
      success: (data) ->
        console.log 'success, ', data
        if data.track isnt undefined
          d =
            track: {}

          d.track = that.track(trackIdentifier,
                               data.track.artist_nm,
                               data.track.album_artist_nm,
                               data.track.album_title,
                               data.track.track_title,
                               data.track.genre_dtl,
                               data.track.len,
                               data.track.release_ymd)
          callback d 
        else
          d =
            kind: that.BUGS_PREFIX + that.ERROR
            track:
              id: trackIdentifier
            msg: "Bugs API data isnt valid for soran."
          callback d
      error: (jqXHR, textStatus, errorThrow) ->
        console.log 'error, ', textStatus
        d =
          kind: that.BUGS_PREFIX + that.ERROR
          msg: "Bugs API dosen't response. error text: #{ textStatus }"
        callback d
    $.ajax options
    true

  getUserIdentifier: (n) ->
    unless this.servicePrefix.length == 0 and n.length == 0
      "#{ n }@#{ this.servicePrefix }"
    else
      ''

  init: (conn) ->
    this.conn = conn
    that = this

    $(document).on 'click', () ->
      bugsUserNameCover = $('.username strong')
      if document.domain is that.BUGS_DOMAIN and bugsUserNameCover.length isnt 0
        that.servicePrefix = that.BUGS_PREFIX
        d =
          kind: that.EVENT_USER_INIT
          identifier: that.getUserIdentifier bugsUserNameCover.text()
        that.conn.postMessage d

  track: (id, artist, albumArtist, albumTitle, title, genre, length, releaseDate) ->
    data =
      identifier: id
      artist: artist
      albumArtist: albumArtist
      albumTitle: albumTitle
      title: title
      genre: genre
      length: length
      releaseDate: releaseDate
    data

__soran.init chrome.extension.connect()