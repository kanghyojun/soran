// Generated by CoffeeScript 1.4.0
(function() {
  var main, runTicking, __soran;

  __soran = {
    BUGS_PREFIX: 'bugs',
    NAVER_PREFIX: 'naverMusic',
    TRACK_POSTFIX: "Track",
    EVENT_USER_INIT: 'userInit',
    EVENT_LISTEN: 'listen',
    BUGS_TRACK_API_URL: "http://music.bugs.co.kr/player/track/",
    BUGS_DOMAIN: 'bugs.co.kr',
    ERROR: 'Error',
    servicePrefix: '',
    isListen: false,
    conn: void 0,
    loggedAt: 80,
    nowPlaying: {
      id: '',
      len: 0
    },
    getBugsTrackInfo: function(n, callback) {
      var options, that, trackIdentifier;
      console.log('getBugsTrackInfo');
      that = this;
      trackIdentifier = this.BUGS_PREFIX + "-" + n;
      options = {
        type: 'GET',
        url: this.BUGS_TRACK_API_URL + n,
        success: function(data) {
          var d;
          console.log('success, ', data);
          if (data.track !== void 0) {
            d = {
              track: {}
            };
            d.track = that.track(trackIdentifier, data.track.artist_nm, data.track.album_artist_nm, data.track.album_title, data.track.track_title, data.track.genre_dtl, data.track.len, data.track.release_ymd);
            return callback(d);
          } else {
            d = {
              kind: that.BUGS_PREFIX + that.ERROR,
              track: {
                id: trackIdentifier
              },
              msg: "Bugs API data isnt valid for soran."
            };
            return callback(d);
          }
        },
        error: function(jqXHR, textStatus, errorThrow) {
          var d;
          console.log('error, ', textStatus);
          d = {
            kind: that.BUGS_PREFIX + that.ERROR,
            msg: "Bugs API dosen't response. error text: " + textStatus
          };
          return callback(d);
        }
      };
      $.ajax(options);
      return true;
    },
    getUserIdentifier: function(n) {
      if (!(this.servicePrefix.length === 0 && n.length === 0)) {
        return "" + n + "@" + this.servicePrefix;
      } else {
        return '';
      }
    },
    init: function(conn) {
      var that;
      this.conn = conn;
      that = this;
      return $(document).on('click', function() {
        var bugsUserNameCover, d;
        bugsUserNameCover = $('.username strong');
        if (document.domain === that.BUGS_DOMAIN && bugsUserNameCover.length !== 0) {
          that.servicePrefix = that.BUGS_PREFIX;
          d = {
            kind: that.EVENT_USER_INIT,
            identifier: that.getUserIdentifier(bugsUserNameCover.text())
          };
          return that.conn.postMessage(d);
        }
      });
    },
    track: function(id, artist, albumArtist, albumTitle, title, genre, length, releaseDate) {
      var data;
      data = {
        identifier: id,
        artist: artist,
        albumArtist: albumArtist,
        albumTitle: albumTitle,
        title: title,
        genre: genre,
        length: length,
        releaseDate: releaseDate
      };
      return data;
    },
    /*
      일정시간마다 웹플레이어가 노래를 어디까지 틀었나 확인한다. 트랙에 길이 __soran.nowPlaying.len 을 이용해서 다음 호출 시점을 정한다.
      @param {string} kind 서비스 이름 PREFIX (eg. __soran.BUGS_PREFIX, ...)
    */

    tick: function(kind, callback) {
      var f, min, nowId, nowPlaying, nowProgress, nowProgressInt, remainPercentage, remainTime, sec, that, time, _ref;
      console.log("ticking started, ", kind);
      that = this;
      time = 0;
      f = function() {
        console.log('applied');
        that.tick.apply(that, [kind, callback]);
        return true;
      };
      switch (kind) {
        case this.BUGS_PREFIX:
          nowProgress = $('.progress .bar').attr('style').substr(7, 2);
          nowPlaying = $('.nowPlaying').find('.trackInfo');
          nowId = nowPlaying.attr('id');
          _ref = nowPlaying.attr('duration').split(":"), min = _ref[0], sec = _ref[1];
          this.nowPlaying.id = nowId;
          min = parseInt(min);
          sec = parseInt(sec);
          this.nowPlaying.len = (sec + (min * 60)) * 1000;
          console.log('1 >', time);
          if (nowPlaying.length === 0) {
            console.log('here, ');
            setTimeout(f, 1000);
            return false;
          }
          if (this.isListen) {
            this.isListen = false;
          }
          console.log('style, ', $('.progress .bar').attr('style'));
          console.log('nowProgress, ', nowProgress);
          if (nowProgress.search('%') === 1 || nowProgress.search('p') === 1) {
            time = this.nowPlaying.len * 0.7;
            console.log('2 >', time);
          } else {
            nowProgressInt = parseInt(nowProgress);
            time = this.nowPlaying.len * 0.05;
            console.log(this.nowPlaying.len);
            if (!this.isListen && this.loggedAt <= nowProgressInt) {
              this.isListen = true;
              remainPercentage = (100 - nowProgressInt) / 100;
              remainTime = this.nowPlaying.len * (remainPercentage + 0.05);
              console.log(remainPercentage);
              console.log('remainTime >', remainTime);
              time = remainTime;
              callback(this.EVENT_LISTEN, this.nowPlaying.id);
            }
            console.log('3 >', time);
          }
          break;
        default:
          this.isListen = false;
          time = 100000;
          return false;
      }
      console.log('4 >', time);
      if (time !== 0) {
        console.log('hey time', time);
        console.log("call ended");
        setTimeout(f, time);
      }
      return this;
    }
  };

  runTicking = function() {
    __soran.tick(__soran.BUGS_PREFIX, function(e, trackNum) {
      var d;
      switch (e) {
        case __soran.EVENT_LISTEN:
          __soran.getBugsTrackInfo(trackNum, function(d) {
            console.log('calling, ', d);
            d.kind = __soran.EVENT_LISTEN;
            return __soran.conn.postMessage(d);
          });
          break;
        default:
          console.log('errored');
          d = {
            kind: __soran.BUGS_PREFIX + __soran.ERROR,
            msg: 'Unknown error occured in f, contentScript.coffee [line: 146]'
          };
          __soran.conn.postMessage(d);
      }
      return true;
    });
    return true;
  };

  main = function() {
    __soran.init(chrome.extension.connect());
    if ($('.progress .bar').length !== 0) {
      return setTimeout(runTicking, 2000);
    }
  };

  $(document).ready(main);

}).call(this);
