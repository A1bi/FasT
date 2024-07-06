import Seating from 'components/ticketing/seating'

export default class extends Seating {
  constructor (container, delegate, zoomable) {
    super(container, delegate, zoomable)

    this.selectedSeats = []
  }

  async init () {
    await super.init()

    this.resetSeats()

    if (this.delegate && typeof (this.delegate.seatSelectorIsReady) === 'function') {
      this.delegate.seatSelectorIsReady()
    }
  }

  clickedSeat (seat) {
    const selected = seat.dataset.status === 'exclusive'
    const seatId = parseInt(seat.dataset.id)
    if (selected) {
      this.selectedSeats.splice(this.selectedSeats.indexOf(seatId), 1)
    } else {
      this.selectedSeats.push(seatId)
    }
    this.setStatusForSeat(seat, selected ? 'available' : 'exclusive')
  }

  setSelectedSeats (seatIds = []) {
    this.resetSeats()
    this.markSeats(seatIds, 'exclusive', seatId => this.selectedSeats.push(seatId))
  }

  getSelectedSeatIds () {
    return this.selectedSeats
  }

  resetSeats () {
    this.selectedSeats = []
    this.markSeats(Object.keys(this.seats), 'available')
  }

  markSeats (seatIds, status, callback) {
    for (const seatId of seatIds) {
      const seat = this.seats[seatId]
      if (!seat) continue

      this.setStatusForSeat(seat, status)
      if (callback) callback(seatId)
    }
  }
}
