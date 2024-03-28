import Step from 'components/ticketing/orders/step'
import { togglePluralText, toggleDisplay, fetch } from 'components/utils'
import SeatChooser from 'components/ticketing/seat_chooser'

export default class extends Step {
  constructor (delegate) {
    super('seats', delegate)

    this.hasSeatingPlan = 'hasSeatingPlan' in this.box.dataset
    if (this.hasSeatingPlan) {
      this.seatingBox = this.box.querySelector('.seat_chooser')
      this.delegate.toggleModalSpinner(true)
      this.chooser = new SeatChooser(this.seatingBox.querySelector('.seating'), this)
      this.chooser.init()

      this.showSeatingBtn = this.box.querySelector('.show-seating-btn')
      this.showSeatingBtn.addEventListener('click', () => {
        toggleDisplay(this.seatingBox, true)
        toggleDisplay(this.showSeatingBtn, false)
        this.resizeDelegateBox()
        this.delegate.updateNextBtn()
      })
    }

    this.datesSelect = this.box.querySelector('#date_id')
    this.datesSelect.addEventListener('change', event => this.choseDate())

    this.reservationGroupCheckboxes = this.box.querySelectorAll(':scope .reservationGroups input[type=checkbox]')
    this.reservationGroupCheckboxes.forEach(checkBox => {
      checkBox.checked = false
      checkBox.addEventListener('click', () => this.enableReservationGroups())
    })
  }

  validate () {
    return !this.hasSeatingPlan || this.chooser.validate()
  }

  needsFullWidth () {
    return !!this.hasSeatingPlan
  }

  nextBtnEnabled () {
    return !!this.info.api.date && (!this.hasSeatingPlan || !this.seatingBox.matches('.d-none'))
  }

  willMoveIn () {
    this.choseDate()

    if (!this.hasSeatingPlan) return

    const info = this.delegate.getStepInfo('tickets')
    if (this.numberOfSeats !== info.internal.numberOfTickets) {
      this.numberOfSeats = info.internal.numberOfTickets
      togglePluralText(this.box.querySelector('.number_of_tickets'), this.numberOfSeats)
      this.chooser.toggleErrorBox(false)
      this.updateSeatingPlan()
    }
  }

  choseDate () {
    const selected = this.datesSelect.selectedOptions[0]
    if (!selected) return

    this.info.api.date = selected.dataset.id
    this.info.internal.boxOfficePayment = 'boxOfficePayment' in selected.dataset
    this.info.internal.localizedDate = selected.textContent

    if (this.hasSeatingPlan) {
      this.updateSeatingPlan()
    } else {
      this.delegate.updateNextBtn()
    }

    this.addBreadcrumb('set date', {
      date: this.info.api.date
    })
  }

  updateSeatingPlan () {
    this.delegate.toggleModalSpinner(true)
    this.chooser.setDateAndNumberOfSeats(
      this.info.api.date, this.numberOfSeats, () => {
        this.delegate.toggleModalSpinner(false)
      }
    )
  }

  enableReservationGroups () {
    const groups = []
    this.reservationGroupCheckboxes.forEach(checkbox => {
      if (checkbox.checked) groups.push(checkbox.name)
    })

    this.delegate.toggleModalSpinner(true)
    fetch(this.box.querySelector('.reservationGroups').dataset.enableUrl, 'post', {
      group_ids: groups,
      event_id: this.delegate.eventId,
      socket_id: this.delegate.getStepInfo('seats').api.socketId
    })
      .then(() => this.resizeDelegateBox())
      .finally(() => this.delegate.toggleModalSpinner(false))
  }

  expire () {
    this.delegate.expire()
    this.addBreadcrumb('session expired')
  }

  seatChooserIsReady () {
    this.info.api.socketId = this.chooser.socketId
    this.delegate.toggleModalSpinner(false)
  }

  seatChooserIsReconnecting () {
    this.delegate.toggleModalSpinner(true)
  }

  seatChooserDisconnected () {
    this.delegate.showModalAlert('Die Verbindung zum Server wurde unterbrochen.<br />Bitte geben Sie Ihre Bestellung erneut auf.<br />Wir entschuldigen uns für diesen Vorfall.')
  }

  seatChooserCouldNotConnect () {
    this.delegate.showModalAlert('Derzeit ist keine Buchung möglich.<br />Bitte versuchen Sie es zu einem späteren Zeitpunkt erneut.')
  }

  seatChooserCouldNotReconnect () {
    this.expire()
  }

  seatChooserExpired () {
    this.expire()
  }
}
