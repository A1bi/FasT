import Step from './step'
import { togglePluralText, fetch } from '../../utils'
import SeatChooser from '../seat_chooser'
import $ from 'jquery'

export default class extends Step {
  constructor (delegate) {
    super('seats', delegate)

    this.hasSeatingPlan = this.box.data('hasSeatingPlan')
    this.seatingBox = this.box.find('.seat_chooser')
    if (this.hasSeatingPlan) {
      this.delegate.toggleModalSpinner(true, true)
      this.box.show()
      this.chooser = new SeatChooser(this.seatingBox.find('.seating'), this)
      this.chooser.init()
      this.box.hide()
    }
    this.seatingBox.hide()

    this.dates = this.box.find('#available_dates option')
    this.box.find('#date_id').change(event => {
      this.choseDate($(event.currentTarget).find(':selected'), true)
    })

    this.box.find('.reservationGroups :checkbox')
      .prop('checked', false).click(() => this.enableReservationGroups())
  }

  validate () {
    return !this.hasSeatingPlan || this.chooser.validate()
  }

  nextBtnEnabled () {
    return !!this.info.api.date
  }

  willMoveIn () {
    this.choseDate(this.dates.filter(':selected'), false)

    if (!this.hasSeatingPlan) return

    const info = this.delegate.getStepInfo('tickets')
    if (this.numberOfSeats !== info.internal.numberOfTickets) {
      this.numberOfSeats = info.internal.numberOfTickets
      togglePluralText(
        this.box.find('.note.number_of_tickets'), this.numberOfSeats
      )
      this.chooser.toggleErrorBox(false)
      this.updateSeatingPlan()
    }
  }

  choseDate ($this, animate) {
    if (!$this) return

    this.info.api.date = $this.data('id')
    this.info.internal.boxOfficePayment = $this.data('box-office-payment')
    this.info.internal.localizedDate = $this.text()

    if (this.hasSeatingPlan) {
      if (animate) {
        this.slideToggle(this.seatingBox, true)
      } else {
        this.seatingBox.show()
      }
      this.updateSeatingPlan()

      window.scrollTo({ top: this.seatingBox.offset().top })
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
    for (const element of this.box.find('.reservationGroups :checkbox')) {
      const $this = $(element)
      if ($this.is(':checked')) groups.push($this.prop('name'))
    }

    this.delegate.toggleModalSpinner(true)
    fetch(this.box.find('.reservationGroups').data('enable-url'), 'post', {
      group_ids: groups,
      event_id: this.delegate.eventId,
      socket_id: this.delegate.getStepInfo('seats').api.socketId
    })
      .then(res => {
        this.resizeDelegateBox()
      })
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
    this.delegate.toggleModalSpinner(true, true)
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
