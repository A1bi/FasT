import { Controller } from '@hotwired/stimulus'
import TicketPrinter from 'components/ticketing/ticket_printer'

export default class extends Controller {
  initialize () {
    this.printer = new TicketPrinter()
  }

  printTickets (event) {
    const path = event.currentTarget.dataset.printablePath
    if (path) {
      this.printer.printTicketsWithNotification(path)
    }
    event.preventDefault()
  }

  printTest (event) {
    const confirmMessage = event.currentTarget.dataset.confirmMessage
    if (!confirmMessage || window.confirm(confirmMessage)) {
      this.printer.printTestWithNotification()
    }
    event.preventDefault()
  }

  openSettings () {
    this.printer.openSettings()
  }
}
