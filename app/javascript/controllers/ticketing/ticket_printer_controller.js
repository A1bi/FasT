import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static outlets = ['ticketing--ticket-printer-popover']

  printTickets (event) {
    const path = event.currentTarget.dataset.printablePath
    if (path) {
      this.ticketingTicketPrinterPopoverOutlet.printTickets(path)
    }
    event.preventDefault()
  }

  printTest (event) {
    const confirmMessage = event.currentTarget.dataset.confirmMessage
    if (!confirmMessage || window.confirm(confirmMessage)) {
      this.ticketingTicketPrinterPopoverOutlet.printTest()
    }
    event.preventDefault()
  }

  openSettings () {
    this.ticketingTicketPrinterPopoverOutlet.openSettings()
  }
}
