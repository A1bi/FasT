import { Controller } from 'stimulus'
import SeatChooser from '../../components/ticketing/seat_chooser'
import { fetch, toggleDisplay } from '../../components/utils'

export default class extends Controller {
  static targets = ['date', 'seatTransfer', 'seating']

  initialize () {
    if (this.hasSeatingTarget) {
      this.seatTransferVisible = false

      this.chooser = new SeatChooser(this.seatingTarget, this)
      this.chooser.init()

      this.reservationGroupBoxes =
        this.element.querySelectorAll('.reservationGroups [type="checkbox"]')
      this.reservationGroupBoxes.forEach(box => {
        box.checked = false
        box.addEventListener('click', () => this.enableReservationGroups())
      })
    }
  }

  get date () {
    return this.dateTarget.value
  }

  get tickets () {
    return JSON.parse(this.element.dataset.tickets)
  }

  set seatTransferVisible (toggle) {
    if (!this.hasSeatTransferTarget) return

    toggleDisplay(this.seatTransferTarget, toggle)
  }

  updateDate () {
    if (!this.chooser) return

    this.seatTransferVisible = !!this.date
    if (!this.date) return

    this.chooser.setDateAndNumberOfSeats(
      this.date, this.tickets.length, () => {}
    )
  }

  enableReservationGroups () {
    const groups = []
    this.reservationGroupBoxes.forEach(box => {
      if (box.checked) groups.push(box.getAttribute('name'))
    })

    const url = this.element.querySelector('.reservationGroups').dataset.enableUrl
    fetch(url, 'post', {
      group_ids: groups,
      event_id: this.element.dataset.eventId,
      socket_id: this.chooser.socketId
    })
      .then(res => this.chooser.toggleExclusiveSeatsKey(res.seats))
  }

  finishTransfer (event) {
    if (!this.date) return window.alert('Bitte wählen Sie ein neues Datum aus.')

    if (this.chooser && this.chooser.getSeatsYetToChoose() > 0) {
      const msg = this.tickets.length > 1 ? `${this.tickets.length} neue Sitzplätze` : 'Ihren neuen Sitzplatz'
      return window.alert(`Bitte wählen Sie ${msg}.`)
    }

    if (!window.confirm(event.currentTarget.dataset.confirmMsg)) return

    if (!this.chooser || this.chooser.validate()) {
      this.makeRequestWithAction('update', 'patch')
        .then(() => this.returnToOrder())
        .catch(() => window.alert(
          'Leider ist bei der Umbuchung ein Fehler aufgetreten.'
        ))
    } else {
      this.element.scrollIntoView({ behavior: 'smooth' })
    }
  }

  makeRequestWithAction (action, method) {
    const url = this.element.dataset[`${action}Path`]
    return fetch(url, method, {
      ticket_ids: this.tickets,
      date_id: this.date,
      socket_id: this.chooser?.socketId
    })
  }

  seatChooserIsReady () {
    this.updateDate()
    this.makeRequestWithAction('init', 'post').catch(() => window.alert(
      'Leider ist bei der Initialisierung ein Fehler aufgetreten.'
    ))
  }

  seatChooserIsReconnecting () {}

  seatChooserDisconnected () {
    window.alert('Die Verbindung zum Server wurde unterbrochen.')
  }

  seatChooserCouldNotReconnect () {
    this.seatChooserDisconnected()
  }

  seatChooserCouldNotConnect () {
    window.alert('Derzeit ist keine Umbuchung möglich.')
  }

  seatChooserExpired () {
    window.alert('Die Sitzung ist abgelaufen.')
  }

  returnToOrder () {
    window.location = this.element.dataset.orderPath
  }
}
