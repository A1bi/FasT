import $ from 'jquery'

export default class {
  static urlScheme = 'fastprint'
  static testDocumentPath = 'uploads/muster.pdf'

  notifyHelper (cmd, options) {
    let url = `${this.constructor.urlScheme}://${cmd}`
    if (options) url += `/${options}`
    window.location.href = url
  }

  printTickets (path) {
    this.notifyHelper('print', path)
  }

  openSettings () {
    this.notifyHelper('settings')
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

    this.notification.find('a.restart').toggle(!!path).off().click(event => {
      this.printTickets(path)
      this.showSpinner(true)
      event.preventDefault()
    })

    if (this.notification.is(':visible')) return

    this.notification.find('a.printable').toggle(!!path).prop('href', path)
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

  printTestWithNotification () {
    this.printTicketsWithNotification(this.constructor.testDocumentPath)
  }
}
