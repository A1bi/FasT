import { Controller } from 'stimulus'
import SeatChooser from '../../components/ticketing/seat_chooser'

export default class extends Controller {
  static targets = ['seating']

  initialize () {
    this.chooser = new SeatChooser(this.seatingTarget, this, false, true)
    this.initChooser()

    window.seating = this
  }

  initChooser () {
    this.chooser.init()
  }

  setDateAndNumberOfSeats (dateId, number) {
    this.chooser.setDateAndNumberOfSeats(dateId, number)
  }

  reset () {
    this.chooser.reset()
  }

  validate () {
    return this.chooser.validate()
  }

  seatChooserIsReady () {
    this.postMessage({
      event: 'becameReady',
      socketId: this.chooser.socketId
    })
  }

  seatChooserDisconnected () {
    this.reinit()
  }

  seatChooserCouldNotConnect () {
    this.reinit()
  }

  seatChooserCouldNotReconnect () {
    this.reinit()
  }

  seatChooserIsReconnecting () {
    this.connecting()
  }

  reinit () {
    this.connecting()

    clearTimeout(this.reinitTimeout)
    this.reinitTimeout = setTimeout(() => this.initChooser(), 1000)
  }

  connecting () {
    this.postMessage({ event: 'connecting' })
  }

  postMessage (data) {
    if (!window.webkit) return

    window.webkit.messageHandlers.seating.postMessage(data)
  }
}
