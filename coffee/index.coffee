window.BORDER_WIDTH = 600
window.RANK_COUNT = 5
window.OUTPUT_FREQUENCY = 100

window.timer = false
window.bests = []
window.worsts = []
window.average = 0
window.count = 0

$().ready ->
  $('input[type="checkbox"]').radiocheck()
  $('#start').on 'click', start
  $('#first').on 'change', changeFirstExplain
  changeFirstExplain()

changeFirstExplain = ->
  if $('#first').prop('checked')
    $('#first_explain').html('バスが来る時間帯の最初にバス停に到着したとする')
  else
    $('#first_explain').html('ランダムな時間にバス停に到着したとする（もうバスが来なければ、バスが来る時間帯の終わりまで待つとする）')

start = ->
  if window.timer is false
    window.BUS_COUNT = Number $('#bus_count').val()
    window.TIME_MINUTES = 60 * Number $('#hour').val()
    window.isFirst = $('#first').prop('checked')
    window.bests = []
    window.worsts = []
    window.average = 0
    window.count = 0
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

calcWait = (me, buses)->
  res = null
  for bus in buses
    wait = bus - me
    res = wait if wait > 0 and (res is null or wait < res)
  res = 1 - me if res is null
  res


add = (buses)->
  # 自分が来る時間を決める
  me = if window.isFirst then 0 else Math.random()
  wait = calcWait(me, buses)

  window.average = (window.average * window.count + wait) / (window.count+1)
  window.count++

  if window.bests.length < window.RANK_COUNT
    window.bests.push {
      me: me
      wait: wait
      buses: buses
    }
  else if window.bests[window.bests.length-1]['wait'] > wait
    window.bests.push {
      me: me
      wait: wait
      buses: buses
    }
    window.bests.sort (a, b)->
      a['wait'] - b['wait']
    window.bests.pop()

  if window.worsts.length < window.RANK_COUNT
    window.worsts.push {
      me: me
      wait: wait
      buses: buses
    }
  else if window.worsts[window.worsts.length-1]['wait'] < wait
    window.worsts.push {
      me: me
      wait: wait
      buses: buses
    }
    window.worsts.sort (a, b)->
      b['wait'] - a['wait']
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


addLines = (results, secondFloat = false)->
  for result in results
    tr = $('<tr>')
    td = $('<td>')
    borderDiv = $('<div>').addClass('graph').css('width', window.BORDER_WIDTH)
    for bus in result['buses']
      $(borderDiv).append(
        $('<span>').addClass('point').html('●').css('left', window.BORDER_WIDTH * bus)
      )
    $(borderDiv).append $('<span>').addClass('point me').html('●').css('left', window.BORDER_WIDTH * result['me'])
    td.append borderDiv
    tr.append td
    tr.append $('<td>').addClass('right').html(timeFormat(result['wait'] * window.TIME_MINUTES, secondFloat))
    $('tbody').append(tr)

timeFormat = (minutes, secondFloat = false)->
  minute = Math.floor minutes
  second = if secondFloat then sprintf('%.4f', (minutes % 1) * 60) else Math.floor((minutes % 1) * 60)
  res = ''
  res += minute+'分' if minute > 0
  res += second+'秒'