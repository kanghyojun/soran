__soran =
  BUGS_PREFIX: 'bugs'
  NAVER_PREFIX: 'naver-music'
  servicePrefix: ''
  isLogin: false
  user:
    name: ''
    identifier: ''
  getUserIdentifier: () ->
    unless this.servicePrefix.length == 0 and this.user.name.length == 0
      "#{ n }@#{ this.servicePrefix }"
    else
      ''

  init: (conn) ->
    this.conn = conn 

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