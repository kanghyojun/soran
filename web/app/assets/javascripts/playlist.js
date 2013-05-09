(function() {
  var BUGS_ARTIST_URL = "http://music.bugs.co.kr/artist/",
      BUGS_ALBUM_URL = "http://music.bugs.co.kr/album/",
      NAVER_ARTIST_URL = "http://music.naver.com/artist/home.nhn?artistId=",
      NAVER_ALBUM_URL = "http://music.naver.com/album/index.nhn?albumId=",
      BUGS_DIRECT_URL = "http://music.bugs.co.kr/newPlayer?trackId=";

  $("#listen tbody tr").each(function(i, e) {
    $e = $(e)
    var music = $e.data("music"),
        count = $e.data("music-count");

    if(music.albumArtist !== void 0 && music.title !== void 0) {
      var splited = $e.attr("id").split("-"),
          serviceName = splited[0],
          trackNum = splited[1],
          getDataColumn = function(titleURL, artistURL, albumURL) {
            return [
              '<td class="title">',
              '<a href="' + titleURL + '">',
              music.title,
              '</a>',
              '</td>',
              '<td class="artist">',
              '<a href="' + artistURL + '">',
              music.artist,
              '</a>',
              '</td>',
              '<td class="album">',
              '<a href="' + albumURL + '">',
              music.albumTitle,
              '</a>',
              '</td>',
              '<td class="count">',
              count,
              '</td>'
            ].join('')
          },
          $td = null;

      if(serviceName == "bugs") {
        var link = BUGS_DIRECT_URL + trackNum;
        $td = $(getDataColumn(
          "javascript:void(window.open('"+link+"', 'Bugs Player', 'width=384,height=667,resizable=0'))",
          BUGS_ARTIST_URL + music.artistId,
          BUGS_ALBUM_URL + music.albumId
        ))
      } else if(serviceName == "naverMusic") {
        $td = $(getDataColumn(
          "http://music.naver.com/search/search.nhn?query=" + encodeURIComponent(music.title + " " + music.artist),
          NAVER_ARTIST_URL + music.artistId,
          NAVER_ALBUM_URL + music.albumId
        ))
      }
      console.log($td)
      if($td !== null) {
        $e.prepend($td)
      }
    }
  });
}).call(this);
