# Music service information API


## Bugs

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

         
         
         
    
    
    
    `var a = $($('tr._tracklist')[0]).data('trackdata').split('|')[0]`
    
    