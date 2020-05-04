window.BORDER_WIDTH = 600
window.RANK_COUNT = 5
window.OUTPUT_FREQUENCY = 100

window.average = 0
window.count = 0
window.timer = false
window.bests = []
window.worsts = []

$().ready ->
  $('#start').on 'click', start


start = ->
  if window.timer is false
    window.BUS_COUNT = Number $('#bus_count').val()
    window.TIME_MINUTES = 60 * Number $('#hour').val()
    window.timer = setInterval(play, 10)
    $('#start').html('ストップ').removeClass('btn-primary').addClass('btn-warning')
  else
    clearInterval window.timer
    window.timer = false
    $('#start').html('スタート').addClass('btn-primary').removeClass('btn-warning')

play = ->
  add sim()
  output() if window.count % window.OUTPUT_FREQUENCY is 0

sim = ->
  buses = []
  for index in [0...window.BUS_COUNT]
    buses.push Math.random()
  buses.sort()
  buses

add = (buses)->
  minutes = buses[0]
  window.average = (window.average * window.count + minutes) / (window.count+1)
  window.count++

  if window.bests.length < window.RANK_COUNT
    window.bests.push buses
  else if window.bests[window.bests.length-1][0] > minutes
    window.bests.push buses
    window.bests.sort (a, b)->
      a[0] - b[0]
    window.bests.pop()

  if window.worsts.length < window.RANK_COUNT
    window.worsts.push buses
  else if window.worsts[window.worsts.length-1][0] < minutes
    window.worsts.push buses
    window.worsts.sort (a, b)->
      b[0] - a[0]
    window.worsts.pop()

output = ->
  $('#average').html(timeFormat(window.average * window.TIME_MINUTES)+' / '+window.count+'回')

  $('tbody').html('')

  # ベスト
  $('tbody').append(
    $('<th>').attr('colspan', '2').html('最短')
  )
  addLines window.bests, true

  # ワースト
  $('tbody').append(
    $('<th>').attr('colspan', '2').html('最長')
  )
  addLines window.worsts


addLines = (buseses, secondFloat = false)->
  for buses in buseses
    tr = $('<tr>')
    td = $('<td>')
    borderDiv = $('<div>').addClass('graph').css('width', window.BORDER_WIDTH)
    for bus in buses
      $(borderDiv).append(
        $('<span>').addClass('point').html('●').css('left', window.BORDER_WIDTH * bus)
      )
    td.append borderDiv
    tr.append td
    tr.append $('<td>').addClass('right').html(timeFormat(buses[0] * window.TIME_MINUTES, secondFloat))
    $('tbody').append(tr)

timeFormat = (minutes, secondFloat = false)->
  minute = Math.floor minutes
  second = if secondFloat then sprintf('%.4f', (minutes % 1) * 60) else Math.floor((minutes % 1) * 60)
  res = ''
  res += minute+'分' if minute > 0
  res += second+'秒'