// Generated by CoffeeScript 1.4.0
(function() {
  var mintpressoAPIKey, _soran;

  mintpressoAPIKey = '48d54bf7e4fa5e7abb6a2f4ecf8b096e::1';

  _soran = {
    BUGS_PREFIX: 'bugs',
    NAVER_PREFIX: 'naverMusic',
    TRACK_POSTFIX: "Track",
    EVENT_USER_INIT: 'userInit',
    EVENT_LISTEN: 'listen',
    BUGS_TRACK_API_URL: "http://music.bugs.co.kr/player/track/",
    SORAN_TYPE_USER: 'user',
    SORAN_TYPE_MUSIC: 'music',
    SORAN_TYPE_ARTIST: 'artist',
    SORAN_VERB_SING: 'sing',
    SORAN_VERB_LISTEN: 'listen',
    ERROR: 'Error',
    user: {
      type: 'user',
      identifier: ''
    },
    addUser: function(identifier) {
      var data;
      console.log('Add user, ', identifier);
      if (identifier.length !== 0 && this.user.identifier !== identifier) {
        this.user.identifier = identifier;
        data = {
          'type': 'user',
          'identifier': identifier
        };
        return mintpresso.set(data);
      }
    },
    addMusic: function(d, callback) {
      var data;
      data = {
        'type': this.SORAN_TYPE_MUSIC,
        'identifier': d.identifier,
        'data': {
          'albumArtist': d.albumArtist,
          'albumTitle': d.albumTitle,
          'artist': d.artist,
          'genre': d.genre,
          'length': d.length,
          'releaseDate': d.releaseDate,
          'title': d.title
        }
      };
      console.log('Add music, ', data);
      return mintpresso.set(data, function(dt) {
        return callback(dt);
      });
    },
    addArtist: function(d, callback) {
      var data;
      data = {
        'type': this.SORAN_TYPE_ARTIST,
        'identifier': d.artist
      };
      console.log('Add artist, ', data);
      return mintpresso.set(data, function(dt) {
        return callback(dt);
      });
    },
    listen: function(user, music, callback) {
      var data;
      data = {};
      data[user.type] = user.identifier;
      data['verb'] = this.SORAN_VERB_LISTEN;
      data[music.type] = music.identifier;
      console.log('listen, ', data);
      return mintpresso.set(data, function(d) {
        return callback(d.status.code === 201 || d.status.code === 200 ? true : false);
      });
    },
    sing: function(artist, music, callback) {
      var data;
      data = {};
      data[artist.type] = artist.identifier;
      data['verb'] = this.SORAN_VERB_SING;
      data[music.type] = music.identifier;
      return mintpresso.set(data, function(d) {
        return callback(d.status.code === 201 || d.status.code === 200 ? true : false);
      });
    }
  };

  chrome.extension.onConnect.addListener(function(port) {
    var tab;
    window["mintpresso"].init(mintpressoAPIKey, {
      withoutCallback: true
    });
    tab = port.sender.tab;
    console.log("added");
    return port.onMessage.addListener(function(data) {
      if (data.kind !== void 0) {
        if (data.kind === _soran.EVENT_USER_INIT) {
          return _soran.addUser(data.identifier);
        } else if (data.kind.length !== 0 && _soran.user.identifier.length !== 0) {
          switch (data.kind) {
            case _soran.BUGS_PREFIX + _soran.ERROR:
              return console.error(data);
            case _soran.EVENT_LISTEN:
              return _soran.addMusic(data.track, function(music) {
                _soran.addArtist(data.track, function(artist) {
                  return _soran.sing(artist, music, function(success) {
                    return console.log(success);
                  });
                });
                return _soran.listen(_soran.user, music, function(success) {
                  return console.log(success);
                });
              });
            default:
              return console.warn(data);
          }
        }
      } else {
        return console.warn("data.kind is undefined.", data);
      }
    });
  });

}).call(this);
