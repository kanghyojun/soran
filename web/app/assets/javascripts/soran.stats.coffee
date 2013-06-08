$stats = $('#stats')

Stats = () ->
  true

Stats.prototype =
  cached: []
  getData: (callback) ->
    if this.cached.length isnt 0
      callback this.cached
    else
      window.soran.getAllEdge identifier, (d) ->
        callback this.cached
  keyDay: (x) ->
    d = new Date(x)
    d.getDay()

  draw: (k) ->
    that = this
    soran.withCircle $stats, this.getData, (d) ->
      keyFunc = null
      switch k
        when 'day' then keyFunc = that.keyDay
        else throw "there is no rules #{ k }"
      d.groupBy keyFunc, (grouped) ->
        console.log grouped

if $stats.length isnt 0
  identifier = $stats.data('identifier')
