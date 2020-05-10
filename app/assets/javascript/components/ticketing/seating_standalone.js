import $ from 'jquery'
import Seating from './seating'

export default class extends Seating {
  constructor (container, zoomable) {
    super(container, null, zoomable)
  }

  async init () {
    await super.init()

    const path = this.container.data('seats-path')
    if (!path) return

    const response = await $.getJSON(path)
    if (!response) return

    if (this.container.is('.chosen')) {
      for (const type of ['taken', 'chosen']) {
        if (!response[type]) continue

        for (const id of response[type]) {
          const seat = this.seats[id]
          if (seat) this.setStatusForSeat(seat, type)
        }
      }
    } else {
      const statuses = { 0: 'taken', 1: 'available', 2: 'exclusive' }
      for (const seatInfo of response.seats) {
        const seat = this.seats[seatInfo[0]]
        if (seat) this.setStatusForSeat(seat, statuses[seatInfo[1]])
      }
    }
  }
}
