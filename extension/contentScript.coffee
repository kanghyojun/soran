__soran =
  BUGS_PREFIX: 'bugs'
  NAVER_PREFIX: 'naverMusic'  
  TRACK_POSTFIX: "Track"
  EVENT_USER_INIT: 'userInit'
  EVENT_LISTEN: 'listen'
  BUGS_TRACK_API_URL: "http://music.bugs.co.kr/player/track/"
  ERROR: 'Error'
  servicePrefix: ''
  isLogin: false
  loggedAt: 80
  user:
    name: ''
    identifier: '' 
  nowPlaying:
    id: ''
    len: 0

  getUserIdentifier: () ->
    unless this.servicePrefix.length == 0 and this.user.name.length == 0
      "#{ n }@#{ this.servicePrefix }"
    else
      ''

  init: (conn) ->
    this.conn = conn 

  track: (id, artist, albumArtist, albumTitle, title, genre, length, releaseDate) ->
    data =
      id: id
      artist: artist
      albumArtist: albumArtist
      albumTitle: albumTitle
      title: title
      genre: genre
      length: length
      releaseDate: releaseDate
    data

__soran.init chrome.extension.connect()