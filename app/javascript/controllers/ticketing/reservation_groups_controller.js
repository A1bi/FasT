import { Controller } from '@hotwired/stimulus'
import SeatSelector from 'components/ticketing/seat_selector'
import { fetch } from 'components/utils'

export default class extends Controller {
  static targets = ['date', 'seating']
  static values = {
    seats: Object,
    dateIds: Array
  }

  initialize () {
    this.seats = this.seatsValue
    this.selector = new SeatSelector(this.seatingTarget, this)
    this.selector.init()
  }

  saveSelectedSeats () {
    this.seats.exclusive[this.date] = this.selector.getSelectedSeatIds()
  }

  updateEvent (event) {
    this.redirectTo(
      `${window.location.pathname}?event_id=${event.currentTarget.value}`
    )
  }

  updateDate () {
    if (this.date) this.saveSelectedSeats()
    this.date = this.dateTarget.value
    this.selector.setSelectedSeats(this.seats.exclusive[this.date])
    this.selector.markSeats(this.seats.taken[this.date], 'taken')
  }

  updateGroup (event) {
    this.redirectTo(this.element.dataset.showPath + event.currentTarget.value)
  }

  applyToAllDates () {
    this.dateIdsValue.forEach(date => {
      this.seats.exclusive[date] = this.selector.getSelectedSeatIds()
    })

    window.alert('Die Blockungen wurden auf alle Termine angewandt.')
  }

  submit () {
    this.saveSelectedSeats()

    fetch(this.element.dataset.updatePath, 'put', {
      seats: this.seats.exclusive
    })
      .then(() => window.alert('Die Blockungen wurden erfolgreich gespeichert.'))
      .catch(() => window.alert('Beim Speichern ist ein unbekannter Fehler aufgetreten.'))
  }

  redirectTo (path) {
    window.location.href = path
  }

  seatSelectorIsReady () {
    this.updateDate()
  }
}
