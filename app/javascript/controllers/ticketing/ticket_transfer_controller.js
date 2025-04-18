import { Controller } from '@hotwired/stimulus'
import SeatChooser from 'components/ticketing/seat_chooser'
import { fetch, toggleDisplay } from 'components/utils'

export default class extends Controller {
  static targets = ['date', 'reservationGroup', 'seatTransfer', 'seating']

  initialize () {
    if (this.hasSeatingTarget) {
      this.seatTransferVisible = false

      this.chooser = new SeatChooser(this.seatingTarget, this)
      this.chooser.init()

      this.reservationGroupTargets.forEach(box => {
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

  // eslint-disable-next-line accessor-pairs
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

  async enableReservationGroups () {
    const groups = []
    this.reservationGroupTargets.forEach(box => {
      if (box.checked) groups.push(box.getAttribute('name'))
    })

    const url = this.element.dataset.reservationGroupEnableUrl
    const res = await fetch(url, 'post', {
      group_ids: groups,
      event_id: this.element.dataset.eventId,
      socket_id: this.chooser.socketId
    })
    this.chooser.toggleExclusiveSeatsKey(res.seats)
  }

  async finishTransfer (event) {
    if (!this.date) return window.alert('Bitte wählen Sie ein neues Datum aus.')

    if (this.chooser && this.chooser.getSeatsYetToChoose() > 0) {
      const msg = this.tickets.length > 1 ? `${this.tickets.length} neue Sitzplätze` : 'Ihren neuen Sitzplatz'
      return window.alert(`Bitte wählen Sie ${msg}.`)
    }

    if (!window.confirm(event.currentTarget.dataset.confirmMsg)) return

    if (!this.chooser || this.chooser.validate()) {
      try {
        await this.makeRequestWithAction('update', 'patch')
        this.returnToOrder()
      } catch {
        window.alert('Leider ist bei der Umbuchung ein Fehler aufgetreten.')
      }
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
