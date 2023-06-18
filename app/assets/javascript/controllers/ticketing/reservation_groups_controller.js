import { Controller } from 'stimulus'
import SeatSelector from '../../components/ticketing/seat_selector'
import { fetch } from '../../components/utils'

export default class extends Controller {
  static targets = ['date', 'seating']

  initialize () {
    try {
      this.seats = JSON.parse(this.element.dataset.seats)
    } catch {
      this.seats = {}
    }
    this.selector = new SeatSelector(this.seatingTarget, this)
    this.selector.init()
  }

  getSelectedSeats () {
    this.seats[this.date] = this.selector.getSelectedSeatIds()
  }

  updateEvent (event) {
    this.redirectTo(
      `${window.location.pathname}?event_id=${event.currentTarget.value}`
    )
  }

  updateDate () {
    if (this.date) {
      this.getSelectedSeats()
    }
    this.date = this.dateTarget.value
    this.selector.setSelectedSeats(this.seats[this.date])
  }

  updateGroup (event) {
    this.redirectTo(this.element.dataset.showPath + event.currentTarget.value)
  }

  save () {
    this.getSelectedSeats()

    fetch(this.element.dataset.updatePath, 'put', {
      seats: this.seats
    })
      .then(() => window.alert(
        'Die Blockungen wurden erfolgreich gespeichert.'
      ))
      .catch(() => window.alert(
        'Beim Speichern ist ein unbekannter Fehler aufgetreten.'
      ))
  }

  redirectTo (path) {
    window.location.href = path
  }

  seatSelectorIsReady () {
    this.updateDate()
  }
}
