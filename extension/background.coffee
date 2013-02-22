chrome.extension.onConnect.addListener (port) ->
  tab = port.sender.tab
  port.onMessage.addListener (info) ->
    console.log info