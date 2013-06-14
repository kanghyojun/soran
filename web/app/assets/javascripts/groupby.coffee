###
  Author: Kang Hyojun ( admire9 at gmail dot com )
###

Fn = () ->
  true

Fn.prototype =
  groupBy: (a, key) ->
    res = {}
    if key is undefined
      throw "key cannot be undefined. you MUST define key function."
    for i in a
      k = key(i)
      if typeof(k) isnt "string"
        throw "key must return `string`"
      unless res.hasOwnProperty(k)
        res[k] = []
      res[k].push(i)
    res
  mapValue: (a, f) ->
    for k, v of a
      a[k] = f(v)
    a
  map: (d, f) ->
    res = []
    for k, v of d
      res.push f(k, v)
    res
  diff: (a, b) ->
    a.filter (i) ->
      not (b.indexOf(i) > -1)

window.soranFn = new Fn()
