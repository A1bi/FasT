import { Controller } from 'stimulus'
import SeatChooser from '../../components/ticketing/seat_chooser'
import { fetch } from '../../components/utils'

export default class extends Controller {
  static targets = ['date', 'seating']

  initialize () {
    if (this.hasSeatingTarget) {
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

  updateDate () {
    if (!this.chooser) return

    this.chooser.setDateAndNumberOfSeats(
      this.date, this.tickets.length, () => {}
    )
  }

  enableReservationGroups () {
    const groups = []
    this.reservationGroupBoxes.forEach(box => {
      if (box.checked) groups.push(box.getAttribute('name'))
    })

    const url =
      this.element.querySelector('.reservationGroups').dataset.enableUrl
    fetch(url, 'post', {
      groups: groups,
      socketId: this.chooser.socketId
    })
      .then(res => this.chooser.toggleExclusiveSeatsKey(res.seats))
  }

  finishTransfer () {
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
    const url = this.element.dataset[`${action}-path`]
    return fetch(url, method, {
      ticket_ids: this.tickets,
      date_id: this.date,
      socketId: this.chooser.socketId
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
    window.location = this.element.dataset['order-path']
  }
}
