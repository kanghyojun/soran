$stats = $('#stats')

Stats = () ->
  true

Stats.prototype =
  cached: ''
  ratio: 0
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
        when 'day'
        then that.drawLinear(soranFn.groupBy(d.content, that.keyDay))
        when 'punchcard'
        then that.drawPunch(soranFn.groupBy(d.content, that.keyDay))
        else throw "there is no rules #{ k }"
      
  sortPunch: (grouped, callback) ->
    day7 = [0..6]
    hours24 = [0..23]
    w = 750
    max = 0
    punchMargin = 1
    circle1002R = ((w - 100) / 24.0) - (punchMargin * 2)
    circle100Radius = circle1002R / 2.0

    mapValueFunc = (v) ->
      g = (x) ->
        d = new Date(x.createdAt)
        d.getHours().toString()
      a = soranFn.groupBy v, g
      soranFn.mapValue a, (x) ->
        x.length
    d = soranFn.mapValue(grouped, mapValueFunc)
    soranFn.map m
    m = (k, v) ->
      d =
        day: k
        hours: v
      d

    data = soranFn.map d, m
    a = []
    currD = data.map (d, i) ->
      d.day
    currD = currD.map (d, i) ->
      parseInt d
    dif = soranFn.diff day7, currD
    for x in dif
      d =
        day: x
        hours: {}
      data.push d
    data = data.map (d, i) ->
      currA = Object.keys(d['hours'])
      currA = currA.map (d, i) ->
        parseInt d
      dif = soranFn.diff hours24, currA
      for x in dif
        d['hours'][x.toString()] = 0
      hours = []
      for k in Object.keys(d['hours'])
        if max < d['hours'][k]
          max = d['hours'][k]
        hd =
          hour: parseInt(k)
          len: d['hours'][k]
        hours.push hd
      hours.qsort (x) ->
        x['hour']
      f =
        day: d['day']
        hours: hours
      f

    data.qsort (x) ->
      x['day']
    this.ratio = circle100Radius / parseFloat(Math.sqrt(max))
    callback data

  drawPunch: (grouped) ->
    that = this
    this.sortPunch grouped, (punchSortedData) ->
      dayText = ['일요일', '월요일', '화요일',
                 '수요일', '목요일', '금요일', '토요일']
      w = 750
      h = 600
      leftMargin = 100
      punchMargin = 1
      circle1002R = ((w - 100) / 24.0) - (punchMargin * 2)
      circle100Radius = circle1002R / 2.0
      heightMarginRatio = (h / 6) * 0.8
      drawPunchCircle = (dest, sortedData) ->
        data = sortedData['hours']
        punchG = dest.selectAll('g').data(data).enter().append('g')
        punchG.attr 'class', 'punch'
        punchG.attr 'transform', (d) ->
          "translate(#{ leftMargin + parseInt(d['hour']) * circle1002R}, 0)"
        info = $(".punch-tooltip")
        circle = punchG.append('circle')
        circle.attr 'cx', 0
        circle.attr 'cy', 0
        circle.attr 'fill', '#494949'
        circle.attr 'r', (d) ->
          Math.sqrt(d['len']) * that.ratio
        circle.on 'mouseover', (d) ->
          h = parseInt(d['hour'])
          dd = parseInt(sortedData['day'])
          info.css 'top', ((dd * heightMarginRatio) - 50) + 240
          info.css 'left', (100 + (circle1002R * h) - 40)
          info.find('.tooltip-inner').html "#{ d['len'] }회 들음"
          info.show()
          c = d3.select(this)
          c.style 'fill', 'steelblue'
        circle.on 'mouseout', (d) ->
          info.hide()
          c = d3.select(this)
          c.style 'fill', '#494949'
        line = punchG.append('line')
        line.attr 'x1', 0
        line.attr 'x2', 0
        line.attr 'y1', (d) ->
          if parseInt(d['hour']) % 2 == 0
            20
          else
            30
        line.attr 'y2', 40
        line.attr 'class', 'punch-line'
          
      drawAxis =(dest, data) ->
        axis = dest.append('line')
        axis.attr 'class', 'punch-axis'
        axis.attr 'x1', 0
        axis.attr 'x2', w
        axis.attr 'y1', 40
        axis.attr 'y2', 40
        
      drawPunchDay = (dest, data) ->
        marginRatio = heightMarginRatio
        yMargin = parseInt(data['day']) * marginRatio
        day = dest.append('g')
        day.attr 'class', 'day'
        day.attr 'transform', "translate(0, #{ yMargin })"
        drawPunchCircle day, data
        drawAxis day, data['hours']
        day.append('text')
            .attr('class', 'day-label')
            .text(dayText[parseInt(data['day'])])
        
      drawChart = (data) ->
        svg = d3.select('#stats')
                .append('svg')
        svg.attr 'width', w
        svg.attr 'height', h
        vis = svg.append('g')
        vis.attr 'transform', 'translate(20, 20)'
        x = d3.scale.linear().range([100, w - 76])
        x.domain [0, 23]
        xAxis = svg.append('g')
        xAxis.attr 'transform', "translate(20, #{ heightMarginRatio * 7})"
        f = (d) ->
          t = d - 12
          if t == 0
            "#{ d }p"
          else if t > 0
            "#{ t }p"
          else
            "#{ d }a"

        axis = d3.svg.axis()
                 .scale(x)
                 .orient("bottom")
                 .tickValues([0..23])
        xAxis.call(axis)
        xAxis.attr 'class', 'x axis'
        xAxis.selectAll('text')
             .text (d) ->
               f(parseInt(d))

        for x in data
          drawPunchDay vis, x
      drawChart punchSortedData

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
  tabActive = ($elem) ->
    l = $elem.closest('.nav').find '.active'
    l.removeClass 'active'
    $elem.closest('li').addClass 'active'
  $('.stat-decision li a').on 'click', (e) ->
    $('#stats svg').remove()
    tabActive $(this)
    soranStats.draw($(this).data('kind'))
