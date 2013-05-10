###
  Author: Kang Hyojun ( admire9 at gmail dot com )

  Rewrite https://gist.github.com/admire93/5547195 in coffeescript
###

Array.prototype.swap = (a, b) ->
  tmp = this[a]
  this[a] = this[b]
  this[b] = tmp

Array.prototype.qsort = (key) ->
  if key is undefined
      key = (x) -> x
  
  findPivot = (a, left, right) ->
    mid = Math.floor(left + (right - left) / 2)
    pivotIndex = null
    if a[left] < a[mid] and a[mid] < a[right]
      pivotIndex = mid
    else if a[left] < a[right]
      pivotIndex = left
    else
      pivotIndex = right

    pivotIndex

  partition = (a, l, r, p) ->
    storeIndex = l
    pivot = key a[p]
    a.swap p, r
    for i in [l..(r - 1)]
      if key(a[i]) <= pivot
        a.swap i, storeIndex
        storeIndex += 1
    a.swap i, storeIndex
    storeIndex
  
  qsort = (l, left, right) ->
    if left < right
      pivotIndex = findPivot l, left, right
      newPivotIndex = partition l, left, right, pivotIndex
      qsort l, left, newPivotIndex - 1
      qsort l, newPivotIndex + 1, right


  qsort this, 0, (this.length - 1)
  this
