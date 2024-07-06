import Seating from 'components/ticketing/seating'
import { fetch } from 'components/utils'

export default class extends Seating {
  constructor (container, zoomable) {
    super(container, null, zoomable)
  }

  async init () {
    await super.init()

    const path = this.container.dataset.seatsPath
    if (!path) return

    const response = await fetch(path)

    if (this.container.matches('.chosen')) {
      for (const type of ['exclusive', 'taken', 'chosen']) {
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
