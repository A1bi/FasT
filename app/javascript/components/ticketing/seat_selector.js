import Seating from 'components/ticketing/seating'

export default class extends Seating {
  constructor (container, delegate, zoomable) {
    super(container, delegate, zoomable)

    this.selectedSeats = []
  }

  async init () {
    await super.init()

    for (const id in this.seats) {
      this.setStatusForSeat(this.seats[id], 'available')
    }

    if (this.delegate && typeof (this.delegate.seatSelectorIsReady) === 'function') {
      this.delegate.seatSelectorIsReady()
    }
  }

  clickedSeat (seat) {
    const selected = seat.data('status') === 'exclusive'
    const seatId = seat.data('id')
    if (selected) {
      this.selectedSeats.splice(this.selectedSeats.indexOf(seatId), 1)
    } else {
      this.selectedSeats.push(seatId)
    }
    this.setStatusForSeat(seat, selected ? 'available' : 'exclusive')
  }

  setSelectedSeats (seats = []) {
    for (const seatId of this.selectedSeats) {
      this.setStatusForSeat(this.seats[seatId], 'available')
    }

    this.selectedSeats = []

    for (const seatId of seats) {
      const seat = this.seats[seatId]
      if (!seat) continue

      this.selectedSeats.push(seatId)
      this.setStatusForSeat(seat, 'exclusive')
    }
  }

  getSelectedSeatIds () {
    return this.selectedSeats
  }
}
