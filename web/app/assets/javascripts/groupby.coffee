###
  Author: Kang Hyojun ( admire9 at gmail dot com )
###

Array.prototype.groupBy = (key, callback) ->
  res = {}
  if key is undefined
    throw "key cannot be undefined. you MUST define key function."
  for i in this
    do (i) ->
      k = key(i)
      if typeof(k) isnt "string"
        throw "key must return `string`"
      if !res.hasOwnProperty(k)
        res[k] = []
      res[k].push(i)

  callback(res)
