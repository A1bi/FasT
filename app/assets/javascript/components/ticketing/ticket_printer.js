export default class {
  static urlScheme = 'fastprint'

  notifyHelper (cmd, options) {
    let url = `${this.constructor.urlScheme}://${cmd}`
    if (options) url += `/${options}`
    window.location.href = url
  }

  printTickets (path) {
    this.notifyHelper('print', path)
  }

  printTest () {
    this.printTickets('uploads/muster.pdf')
  }

  openSettings () {
    this.notifyHelper('settings')
  }
}
