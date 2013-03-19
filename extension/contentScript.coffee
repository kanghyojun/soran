__soran =
  BUGS_PREFIX: 'bugs'
  NAVER_PREFIX: 'naverMusic'  
  TRACK_POSTFIX: "Track"
  EVENT_USER_INIT: 'userInit'
  EVENT_LISTEN: 'listen'
  BUGS_TRACK_API_URL: "http://music.bugs.co.kr/player/track/"
  NAVER_TRACK_API_URL: "http://player.music.naver.com/api.nhn?m=songinfo&trackid="
  BUGS_DOMAIN: 'bugs.co.kr'
  NAVER_DOMAIN: 'naver.com'
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

  ###
  일정시간마다 웹플레이어가 노래를 어디까지 틀었나 확인한다. 트랙에 길이 __soran.nowPlaying.len 을 이용해서 다음 호출 시점을 정한다.
  @param {string} kind 서비스 이름 PREFIX (eg. __soran.BUGS_PREFIX, ...)
  ###
  tick: (kind, callback) ->
    console.log "ticking started, ", kind
    that = this
    time = 0
    f = ->
      console.log 'applied'
      that.tick.apply(that, [kind, callback])
      true

    switch (kind)
      when this.BUGS_PREFIX
        nowProgress = $('.progress .bar').attr('style').substr(7, 2)
        nowPlaying = $('.nowPlaying').find('.trackInfo')
        nowId = nowPlaying.attr('id')
        [min, sec] = nowPlaying.attr('duration').split(":")
        this.nowPlaying.id = nowId
        min = parseInt min
        sec = parseInt sec
        this.nowPlaying.len = (sec + (min * 60)) * 1000
        console.log '1 >', time
        if nowPlaying.length is 0 
          console.log 'here, '
          setTimeout f, 1000
          return false

        if this.isListen 
          this.isListen = false

        console.log 'style, ', $('.progress .bar').attr('style')
        console.log 'nowProgress, ', nowProgress
        if nowProgress.search('%') == 1 or nowProgress.search('p') == 1
          time = this.nowPlaying.len * 0.7
          console.log '2 >', time
        else
          nowProgressInt = parseInt(nowProgress)
          time = this.nowPlaying.len * 0.05
          console.log this.nowPlaying.len
          if not this.isListen and this.loggedAt <= nowProgressInt 
            this.isListen = true
            remainPercentage = (100 - nowProgressInt) / 100
            remainTime = this.nowPlaying.len * (remainPercentage + 0.05)
            console.log remainPercentage
            console.log 'remainTime >', remainTime
            time = remainTime
            callback this.EVENT_LISTEN, this.nowPlaying.id
          console.log '3 >', time
      else
        this.isListen = false
        time = 100000
        return false

    console.log '4 >', time
    if time isnt 0
      console.log 'hey time', time
      console.log "call ended"
      setTimeout(f, time)
    this


runTicking = () ->
  __soran.tick __soran.BUGS_PREFIX, (e, trackNum) ->
    switch (e)
      when __soran.EVENT_LISTEN
        __soran.getBugsTrackInfo trackNum, (d) ->
          console.log 'calling, ', d
          d.kind = __soran.EVENT_LISTEN
          __soran.conn.postMessage d
      else
        console.log 'errored'
        d =
          kind: __soran.BUGS_PREFIX + __soran.ERROR
          msg: 'Unknown error occured in f, contentScript.coffee [line: 146]'
        __soran.conn.postMessage d
    true
  true

main = ->
  __soran.init chrome.extension.connect() 
  if $('.progress .bar').length != 0 
    setTimeout runTicking, 2000

$(document).ready main