mintpressoAPIKey = '48d54bf7e4fa5e7abb6a2f4ecf8b096e::1'

_soran =
  BUGS_PREFIX: 'bugs'
  NAVER_PREFIX: 'naverMusic'  
  TRACK_POSTFIX: "Track"
  EVENT_USER_INIT: 'userInit'
  EVENT_LISTEN: 'listen'
  BUGS_TRACK_API_URL: "http://music.bugs.co.kr/player/track/"
  SORAN_TYPE_USER: 'user' 
  SORAN_TYPE_MUSIC: 'music'
  SORAN_TYPE_ARTIST: 'artist'
  SORAN_VERB_SING: 'sing'
  SORAN_VERB_LISTEN: 'listen'
  ERROR: 'Error'
  user:
    type: 'user'
    identifier: ''

  addUser: (identifier) ->
    console.log 'Add user, ', identifier
    if identifier.length isnt 0 and this.user.identifier isnt identifier
      this.user.identifier = identifier
      data = 
        'type': 'user'
        'identifier': identifier
      mintpresso.set data

  addMusic: (d, callback) ->
    data =
      'type': this.SORAN_TYPE_MUSIC
      'identifier': d.identifier
      'data':
        'albumArtist': d.albumArtist
        'albumTitle': d.albumTitle
        'artist': d.artist
        'genre': d.genre
        'length': d.length
        'releaseDate': d.releaseDate
        'title': d.title
    console.log 'Add music, ', data
    mintpresso.set data, (dt) ->
      callback dt

  addArtist: (d, callback) ->
    data =
      'type': this.SORAN_TYPE_ARTIST
      'identifier': d.artist
    console.log 'Add artist, ', data
    mintpresso.set data, (d) ->
      callback d

  listen: (user, music, callback) ->
    console.log 'listen, ', user, music
    callback true

  sing: (artist, music, callback) ->
    console.log 'sing, ', artist, music
    callback true


chrome.extension.onConnect.addListener (port) ->
  window["mintpresso"].init(mintpressoAPIKey, {withoutCallback: true})
  tab = port.sender.tab 
  console.log "added"
  port.onMessage.addListener (data) ->
    if data.kind isnt undefined
      if data.kind is _soran.EVENT_USER_INIT
        _soran.addUser data.identifier
      else if data.kind.length isnt 0 and _soran.user.identifier.length isnt 0
          switch data.kind
            when _soran.BUGS_PREFIX + _soran.ERROR
              console.error data
            when _soran.EVENT_LISTEN
              _soran.addMusic data.track, (music) ->
                _soran.addArtist data.track, (artist) ->
                  _soran.sing artist, music, (success) ->
                    console.log success
                _soran.listen _soran.user, music, (success) ->
                  console.log success
            else
              console.warn data
    else
      console.error "data.kind is undefined."