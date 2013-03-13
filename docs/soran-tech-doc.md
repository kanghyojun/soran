# Music service information API


## Bugs
### [player](http://www.bugs.co.kr/swf/BugsNewPlayer.swf?version=201301010350)

`object#BugsPlayer` 엘리먼트에서 플레이중,

`bugs.player`는 웹플레이어 오브젝트이고, Flash 플레이어 오브젝트가 컨테이너로 올라와있다.[^1]

### url 

 - http://music.bugs.co.kr/player/track/:trackId

JSON으로 리턴됨.

### Query Param

  - trackId: 유저가 생성한 플레이리스트에 저장했을때, 고유한 trackId가 생성된다. `.trackInfo`에 `id` attribute에 저장되어있다.

### How to write our music log in Bugs

`bugs.player.handleEvent`에서 웹플레이어이 안에 모든 이벤트를 관리한다. 내부적으로는 다음과 비슷하게 처리하고있다.

    bugs.player = {
      ...
      handleEvent = function(event) = {
        var event = arguments[0] // 왜 여기서 구지 arguments로 다시받는지는 모르겠다.
        switch(event) {
          case "blah": doSomething(); break;
          ....
          default: break;
        }
      }
    }

위 이벤트 중 `playTrackChange`를 추적하여 우리들의 로그를 남기면 될것같다. 구현방법은 다음과같다. 원래 함수를 한번 wrap하여 우리가 하고싶은 일을 실행시키고, 원래 함수를 호출한다.

    #/bin/coffee

    _handleEvent = bugs.player.handleEvent
    bugs.player.handleEvent = () ->
      doSomethingRelatedSoran();
      _handleEvent.apply(bugs.player, argument)

  
## Naver Music

`nhn.FlashObject.find("NMP_web_player_container")`로 `JSFlash` 오브젝트 내부에 `_oStreamingCore` 생성한 후에, 이 변수로 재생, 정지를 관리하는거같다.

    // From naver source
    var _local3:NaverMusicPlayerBasicEvent = new NaverMusicPlayerBasicEvent(NaverMusicPlayerBasicEvent.PLAY_CURRENT_SONG, true);
    _local3.data = {
      trackId:_arg1.getTrackID(),
      auto:_arg2
    };
    dispatchEvent(_local3);

`NaverMusicPlayerBasicEvent`를 dispatch해서 쓴다.
### url

 - http://player.music.naver.com/api.nhn?trackid=:traciId&m=songinfo
 
URI encoded STRING으로 리턴됨.

### Query Param

 - trackId: `tr._tracklist`에 `trackdata`에 맨처음에 저장되어있음. `|`로 split해서 가져오면됨.
 
.
    
    
    var a = $($('tr._tracklist')[0]).data('trackdata').split('|')[0]

[^1]: [여기](./bugs.source.txt)에 벅스 플레이어 swf 디컴파일한 소스가있다.
    
