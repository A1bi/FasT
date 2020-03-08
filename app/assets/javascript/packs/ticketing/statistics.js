/* global Seating, Seat */

import '../../../javascripts/ticketing/_seating'
import $ from 'jquery'

$(() => {
  $('.chooser span').click(async event => {
    const $this = $(event.currentTarget)
    $this.addClass('selected').siblings().removeClass('selected')
    $('.stats *').stop(true, false)

    const tableClass = '.' + $this.data('table')
    const tables = $('.stats .table:visible')
    await tables.not(tableClass).slideUp(600).promise()
    tables.siblings(tableClass).slideDown()
  })

  const seatingBoxes = $('.seating')
  if (seatingBoxes.length) {
    $.getJSON(seatingBoxes.first().data('additional-path'), data => {
      if (!data) return

      for (const box of seatingBoxes) {
        const $box = $(box)
        const dateSeats = data.seats[$box.data('date')]
        var seating = new Seating($box)
        seating.initSeats(seat => {
          var status
          switch (dateSeats[seat.id]) {
            case 2:
              status = Seat.Status.Exclusive
              break
            case 1:
              status = Seat.Status.Available
              break
            default:
              status = Seat.Status.Taken
          }
          seat.setStatus(status)
        })
      }
    })
  }
})
