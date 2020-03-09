/* global $ */

import { Controller } from 'stimulus'
import TicketPrinter from '../../components/ticketing/ticket_printer'

export default class extends Controller {
  initialize () {
    this.printer = new TicketPrinter()
  }

  printTest (event) {
    const confirmMessage = event.currentTarget.dataset.confirmMessage
    if (!confirmMessage || window.confirm(confirmMessage)) {
      this.printer.printTest()
    }
  }

  openSettings () {
    this.printer.openSettings()
  }

  showPrintNotification (path) {
    if (!this.notification) {
      this.notification = $('.print-notification')
      this.notification.find('a.dismiss').click(event => {
        this.notification.fadeOut()
        event.preventDefault()
      })
      this.spinner = this.notification.find('.spinner')
    }

    this.notification.find('a.restart').off().click(event => {
      this.printTickets(path)
      this.showSpinner(true)
      event.preventDefault()
    })

    if (this.notification.is(':visible')) return

    this.notification.find('a.printable').prop('href', path)
    this.showSpinner()
    this.notification.fadeIn()
  }

  showSpinner (fadeIn) {
    this.spinner.fadeIn()

    setTimeout(() => this.spinner.fadeOut(), 5000)
  }

  printTicketsWithNotification (path) {
    this.printTickets(path)
    this.showPrintNotification(path)
  }
}
