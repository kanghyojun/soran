__soran =
  BUGS_PREFIX: 'bugs'
  NAVER_PREFIX: 'naverMusic'  
  TRACK_POSTFIX: "Track"
  EVENT_USER_INIT: 'userInit'
  EVENT_LISTEN: 'listen'
  BUGS_ARTIST_URL: "http://music.bugs.co.kr/artist/"
  BUGS_ALBUM_URL: "http://music.bugs.co.kr/album/"
  NAVER_ARTIST_URL: "http://music.naver.com/artist/home.nhn?artistId="
  NAVER_ALBUM_URL: "http://music.naver.com/album/index.nhn?albumId="
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
        decoded = JSON.parse decodeURIComponent(data)
        nTrack = decoded.resultvalue[0]
        d =
          track: {}
        artistName = nTrack.artist[0].artistname.replace('+', ' ')
        albumArtist = if nTrack.artist.length == 1 then artistName else "Various Artist"

        d.track = that.track(
          trackIdentifier,
          artistName,
          nTrack.artist[0].artistid,
          albumArtist,
          nTrack.album.albumtitle.replace('+', ' '),
          nTrack.album.albumid,
          nTrack.tracktitle.replace('+', ' '),
          "unknown",
          jQuery('.progress .total_time').text(),
          "unknown"
        )
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
                               data.track.artist_id,
                               data.track.album_artist_nm,
                               data.track.album_title,
                               data.track.album_id,
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

  init: (service, conn) ->
    this.conn = conn
    that = this
    jQuery(document).on 'click', ->
      $bugsUserNameCover = jQuery('.username strong')
      $naverUserNameCover = jQuery('strong#gnb_nicknm_txt')
      cover = null
      name = ""
      if service is that.BUGS_PREFIX and $bugsUserNameCover.length isnt 0
        that.servicePrefix = that.BUGS_PREFIX
        name = $bugsUserNameCover.text()
      else if service is that.NAVER_PREFIX and $naverUserNameCover.length isnt 0
        that.servicePrefix = that.NAVER_PREFIX
        tmpName = $naverUserNameCover.text()
        name = tmpName.substring(0, tmpName.length - 1)

      if that.servicePrefix.length isnt 0 and name.length isnt 0
        d =
          kind: that.EVENT_USER_INIT
          identifier: that.getUserIdentifier name
        that.conn.postMessage d  

  track: (id, artist, artistId, albumArtist, albumTitle, albumId, title, genre, length, releaseDate) ->
    data =
      identifier: id
      artist: artist
      artistId: artistId
      albumArtist: albumArtist
      albumTitle: albumTitle
      albumId: albumId
      title: title
      genre: genre
      len: length
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

    switch kind
      when this.BUGS_PREFIX
        thisService = this.BUGS_PREFIX
        nowProgress = jQuery('.progress .bar').attr('style').substr(7, 2)
        nowPlaying = jQuery('.nowPlaying').find('.trackInfo')
        if nowPlaying.length is 0 
          setTimeout f, 1000
          return false 
        else
          nowId = nowPlaying.attr('id')
          nowLen = nowPlaying.attr('duration')
          this.nowPlaying.id = nowId
          console.log 'nowProgress, ', nowProgress 
      when this.NAVER_PREFIX
        thisService = this.NAVER_PREFIX 
        $nowProgressBar = jQuery('.slider .play_value')

        if $nowProgressBar.length is 0
          setTimeout f, 1000
          return false
        else
          nowProgress = $nowProgressBar.attr('style').substr(7, 2)
          $nowPlayingTd = jQuery('.play_list_table tr.playing td.title') 
          nowLen = jQuery('.progress .total_time').text()
          this.nowPlaying.id = $nowPlayingTd.attr('class').split(" ")[0].split(",")[1].split(":")[1]
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
          kind: __soran.servicePrefix + __soran.ERROR
          msg: 'Unknown error occured in f, contentScript.coffee [line: 228]'
        __soran.conn.postMessage d
    true
  true

main = (s) ->
  __soran.init s, chrome.extension.connect() 
  if jQuery('.progress .bar').length isnt 0 or jQuery('.slider .play_value').length isnt 0
    wrap = ->
      runTicking s 

    setTimeout wrap, 2000

switch document.domain
  when __soran.NAVER_DOMAIN
    main __soran.NAVER_PREFIX
  when __soran.BUGS_DOMAIN
    main __soran.BUGS_PREFIX 