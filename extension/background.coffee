mintpressoAPIKey = '48d54bf7e4fa5e7abb6a2f4ecf8b096e::1'

_soran = 
  user:
    name: ''
    mintpresso: ''

  addUser: (info) ->
    if info.name.length != 0 and this.user.name != info.name
      this.user.name = info.name
      data = 
        type: 'user'
        identifier: "bugs-#{ this.user.name }"
      mintpresso.set data

  addMusic: (info, callback) ->
    data =
      type: "music"
      identifier: "#{ info.serviceName }-#{ info.id }"
      data:
        albumArtist: info.albumArtist
        albumTitle: info.albumTitle
        artist: info.artist
        genre: info.genre
        length: info.length
        releaseDate: info.releaseDate
        title: info.title
    mintpresso.set data

  listenMusic: (music) ->
    true

chrome.extension.onConnect.addListener (port) ->
  window["mintpresso"].init(mintpressoAPIKey, {withoutCallback: true})
  tab = port.sender.tab 
  port.onMessage.addListener (info) ->
    switch info.kind
      when 'bugsUserName'
        _soran.addUser(info)
      when 'bugsTrack'
        _soran.addMusic info, (m) ->
          _soran.listenMusic m
   