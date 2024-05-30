import { Controller } from '@hotwired/stimulus'
import { toggleDisplay } from 'components/utils'

export default class extends Controller {
  static targets = ['spinner', 'ticketsLink']
  static urlScheme = 'fastprint'
  static testDocumentPath = '/uploads/muster.pdf'

  printTickets (path) {
    if (typeof path === 'string') {
      this.currentTicketsPath = path
    } else if (path instanceof CustomEvent) {
      this.currentTicketsPath = path.detail.path
    }
    this.ticketsLinkTarget.setAttribute('href', this.currentTicketsPath)
    toggleDisplay(this.element, true)
    this.showSpinner()
    this.notifyHelper('print', this.currentTicketsPath)
  }

  printTest () {
    this.printTickets(this.constructor.testDocumentPath)
  }

  openSettings () {
    this.notifyHelper('settings')
  }

  notifyHelper (cmd, options) {
    let url = `${this.constructor.urlScheme}://${cmd}`
    if (options) url += `/${options}`
    window.location.href = url
  }

  showSpinner () {
    toggleDisplay(this.spinnerTarget, true)
    setTimeout(() => toggleDisplay(this.spinnerTarget, false), 5000)
  }
}
