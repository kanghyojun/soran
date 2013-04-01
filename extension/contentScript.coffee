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

  getNaverTrackInfo: (n, callback) ->
    console.log 'getNaverTrackInfo'
    that = this
    trackIdentifier = this.NAVER_PREFIX + "-" + n
    options =
      type: 'GET'
      url: this.NAVER_TRACK_API_URL + n
      success: (data) ->
        decoded = decodeURIComponent data
        nTrack = decoded.resultvalue[0]
        d =
          track: {}

        artistName = nTrack.artist[0].artistname.replace('+', ' ')
        albumTitle = nTrack.album.albumtitle.replace('+', ' ')
        trackTitle = nTrack.tracktitle.replace('+', ' ')
        d.track = that.track(trackIdentifier,
                             artistName,
                             artistName,
                             albumTitle,
                             tracktitle,
                             "Unknown",
                             that.nowPlaying.len,
                             "Unknown")
        callback d
      error: (jqXHR, textStatus, errorThrow) ->
        console.log 'error, ', textStatus
        d =
          kind: that.BUGS_PREFIX + that.ERROR
          msg: "Bugs API dosen't response. error text: #{ textStatus }"
        callback d

    jQuery.ajax options

  getBugsTrackInfo: (n, callback) ->
    console.log 'getBugsTrackInfo'
    that = this
    trackIdentifier = this.BUGS_PREFIX + "-" + n
    options =
      type: 'GET'
      url: this.BUGS_TRACK_API_URL + n
      success: (data) ->
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
    jQuery.ajax options
    true

  getUserIdentifier: (n) ->
    unless this.servicePrefix.length == 0 and n.length == 0
      "#{ n }@#{ this.servicePrefix }"
    else
      ''

  init: (conn) ->
    this.conn = conn
    that = this

    jQuery(document).on 'click', () ->
      bugsUserNameCover = jQuery('.username strong')
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
    nowProgress = 0
    nowLen = ''
    thisService = ''
    f = ->
      console.log 'applied'
      that.tick.apply(that, [kind, callback])
      true

    if this.isListen 
      this.isListen = false

    switch (kind)
      when this.BUGS_PREFIX
        thisService = this.BUGS_PREFIX
        nowProgress = jQuery('.progress .bar').attr('style').substr(7, 2)
        nowPlaying = jQuery('.nowPlaying').find('.trackInfo')
        nowId = nowPlaying.attr('id')
        nowLen = nowPlaying.attr('duration')
        this.nowPlaying.id = nowId
        console.log '1 >', time
        if nowPlaying.length is 0 
          console.log 'here, '
          setTimeout f, 1000
          return false 

        console.log 'style, ', jQuery('.progress .bar').attr('style')
        console.log 'nowProgress, ', nowProgress 
      when this.NAVER_PREFIX
        thisService = this.NAVER_PREFIX
        nowProgress = $$.getSingle('.progress .play_value').style.width.substr(0,2)
        $nowPlayingTd = $$.getSingle('.play_list_table tr.playing td.title') 
        nowLen = $$.getSingle('.progress .total_time').textContent
        [r, i] = $nowPlayingTd.classList.item(0).substr(4).split(',')
        this.nowPlaying.id = i.split(":")[1]
      else
        this.isListen = false
        time = 100000
        return false

    [min, sec] = nowLen.split(":")
    min = parseInt min
    sec = parseInt sec
    this.nowPlaying.len = (sec + (min * 60)) * 1000 
    if nowProgress.search('%') == 1 or nowProgress.search('p') == 1
      time = this.nowPlaying.len * 0.7
    else
      nowProgressInt = parseInt(nowProgress)
      time = this.nowPlaying.len * 0.05
      if not this.isListen and this.loggedAt <= nowProgressInt 
        this.isListen = true
        remainPercentage = (100 - nowProgressInt) / 100
        remainTime = this.nowPlaying.len * (remainPercentage + 0.05)
        time = remainTime
        callback "#{thisService}#{this.EVENT_LISTEN}", this.nowPlaying.id
    if time isnt 0
      setTimeout(f, time)
    else
      setTimeout f, 10000
    this


runTicking = (prefix) ->
  __soran.tick prefix, (e, trackNum) ->
    switch (e)
      when __soran.BUGS_PREFIX + __soran.EVENT_LISTEN 
        __soran.getBugsTrackInfo trackNum, (d) ->
          d.kind = __soran.EVENT_LISTEN
          __soran.conn.postMessage d
      when __soran.NAVER_PREFIX + __soran.EVENT_LISTEN
        __soran.getNaverTrackInfo trackNum, (d) ->
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

main = (s) ->
  __soran.init s, chrome.extension.connect() 
  if jQuery('.progress .bar').length isnt 0 or jQuery('.progress .play_value').length isnt 0
    wrap = ->
      runTicking s

    setTimeout wrap, 2000

switch document.domain
  when __soran.NAVER_DOMAIN
    main __soran.NAVER_PREFIX
  when __soran.BUGS_DOMAIN
    main __soran.BUGS_PREFIX 