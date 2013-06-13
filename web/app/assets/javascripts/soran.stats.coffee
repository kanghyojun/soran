$stats = $('#stats')

Stats = () ->
  true

Stats.prototype =
  cached: ''
  getData: (callback) ->
    that = this
    if this.cached.length isnt 0
      callback JSON.parse(this.cached)
    else
      window.soran.getAllEdge this.identifier, (d) ->
        that.cached = d
        callback JSON.parse(d)
  keyDay: (x) ->
    d = new Date(x.createdAt)
    d.getDay().toString()

  draw: (k) ->
    that = this
    soran.withCircle $stats, this, this.getData, [], (d) ->
      keyFunc = null
      switch k
        when 'day' then that.drawLinear(soranFn.groupBy(d.content, that.keyDay))
        else throw "there is no rules #{ k }"
      
  drawLinear: (grouped) ->
    mapValueFunc = (v) ->
      v.length

    grouped = soranFn.mapValue grouped, mapValueFunc
    mapFunc = (k, v) ->
      d =
        kind: k
        value: v
      d

    data = soranFn.map grouped, mapFunc
    listenDays = data.map (d, i) ->
      d.kind

    diff = soranFn.diff ["0", "1", "2", "3", "4", "5", "6"], listenDays
    if diff.length isnt 0
      for x in diff
        d =
          kind: x
          value: 0
        data.push d

    day = ['Sun', 'Mon', 'Tue', 'Wed', 'Thr', 'Fri', 'Sat']
    sortFunc = (d) ->
      d.kind

    data.qsort sortFunc
    w = 700
    h = 300
    xf = d3.scale.linear().range([0, w])
    yf = d3.scale.linear().range([h-50, 0])
    xAxis = d3.svg.axis()
            .scale(xf)
            .orient("bottom")

    yAxis = d3.svg.axis().tickSize(-w).tickSubdivide(true)
            .scale(yf)
            .orient("left")
    line = d3.svg.line()
    line.x (d) ->
      xf parseInt(d.kind)

    line.y (d) ->
      yf d.value

    line.interpolate 'monotone'

    xf.domain [-1, data.length - 1]
    yE = d3.extent data, (d) ->
      d.value
    yf.domain yE
    svg = d3.select('#stats')
            .append('svg')
            .attr('width', w + 150)
            .attr('height', h + 50)
    svg = svg.append("g")
             .attr("transform", "translate(40, 50)")

    x = svg.append 'g'
    x.call xAxis
    x.attr("transform", "translate(0, #{ h - 50 })")
    x.attr('class', 'x axis')
    y = svg.append 'g'
    y.call yAxis
    y.attr('class', 'y axis')
    path = svg.append('path')
    path.datum(data)
    path.attr('class', 'line')
    path.attr 'd', line
    x.selectAll('text')
     .text (d) ->
       if d is -1
         ""
       else
         day[parseInt d]
    circle = svg.selectAll('circle')
               .data(data)
               .enter().append('circle')
               .attr('r', 10)
               .attr("fill", "white")
               .attr("stroke", "steelblue")
    circle.attr 'stroke-width', 2
    circle.attr 'cx', (d, i) ->
      xf(parseInt(d.kind))

    circle.attr 'cy', (d) ->
      yf(d.value)

    circle.on 'mouseover', (d) ->
      c = d3.select(this)
      unless c.attr('r') is '30'
        c.attr 'r', 30
        ctxt = svg.append('text').text("#{ d.value }번")
        ctxt.attr 'class', 'info'
        ctxt.attr 'x', xf(parseInt(d.kind))
        ctxt.attr 'y', yf(d.value)
        ctxt.attr 'id', "ctxt-#{ d.kind }"
        ctxt.style 'text-anchor', 'middle'
        ctxt.style 'font-size', '20px'

    circle.on 'click', (d) ->
      d3.select(this).attr 'r', 10
      d3.selectAll("#ctxt-#{ d.kind }").remove()

    true

window.soranStats = new Stats()
if $stats.length isnt 0
  identifier = $stats.data('identifier')
  soranStats.identifier = identifier
  soranStats.draw('day')
