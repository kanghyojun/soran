# Music service information API


## Bugs
### [player](http://www.bugs.co.kr/swf/BugsNewPlayer.swf?version=201301010350)

`object#BugsPlayer` 엘리먼트에서 플레이중,

`bugs.player.playlist.player` 오브젝트가 실제 플레이어 오브젝트인듯하다.[^1]

### url 

 - http://music.bugs.co.kr/player/track/:trackId

JSON으로 리턴됨.

### Query Param

  - trackId: 유저가 생성한 플레이리스트에 저장했을때, 고유한 trackId가 생성된다. `.trackInfo`에 `id` attribute에 저장되어있다.
  
## Naver Music

### url

 - http://player.music.naver.com/api.nhn?trackid=:traciId&m=songinfo
 
URI encoded STRING으로 리턴됨.

### Query Param

 - trackId: `tr._tracklist`에 `trackdata`에 맨처음에 저장되어있음. `|`로 split해서 가져오면됨.
 
.
    
    
    var a = $($('tr._tracklist')[0]).data('trackdata').split('|')[0]

[^1]: [여기](./bugs.source.txt)에 벅스 플레이어 swf 디컴파일한 소스가있다.
    
