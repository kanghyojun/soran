BUGS_ARTIST_URL = "http://music.bugs.co.kr/artist/"
BUGS_ALBUM_URL = "http://music.bugs.co.kr/album/"
NAVER_ARTIST_URL = "http://music.naver.com/artist/home.nhn?artistId="
NAVER_ALBUM_URL = "http://music.naver.com/album/index.nhn?albumId="
BUGS_DIRECT_URL = "http://music.bugs.co.kr/newPlayer?trackId="


$("#listen tbody tr").each (i, e) ->
  $e = $(e)
  music = $e.data("music")
  count = $e.data("music-count")
  if music.albumArtist isnt undefined and music.title isnt undefined
    splited = $e.attr("id").split("-")
    serviceName = splited[0]
    trackNum = splited[1]
    getDataColumn = (titleURL, artistURL, albumURL) ->
      [
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

    $td = null
    if serviceName is "bugs"
      link = BUGS_DIRECT_URL + trackNum;
      $td = $(getDataColumn(
        "javascript:void(window.open('#{ link }', 'Bugs Player', 'width=384,height=667,resizable=0'))",
        BUGS_ARTIST_URL + music.artistId,
        BUGS_ALBUM_URL + music.albumId
      ))
    else if serviceName is "naverMusic"
      $td = $(getDataColumn(
        "http://music.naver.com/search/search.nhn?query=" + encodeURIComponent(music.title + " " + music.artist),
        NAVER_ARTIST_URL + music.artistId,
        NAVER_ALBUM_URL + music.albumId
      ))

    if $td isnt null
      $e.prepend $td