import Step from 'components/ticketing/orders/step'
import TicketPrinter from 'components/ticketing/ticket_printer'

export default class extends Step {
  constructor (delegate) {
    super('finish', delegate)
  }

  willMoveIn () {
    const payInfo = this.delegate.getStepInfo('payment')
    if (payInfo) {
      this.box.find('.items').toggle(payInfo.api.method === 'charge')
    }

    const confirmInfo = this.delegate.getStepInfo('confirm')
    const orderInfo = confirmInfo.internal.order
    orderInfo.total = Number.parseFloat(orderInfo.total)

    if (this.delegate.retail) {
      this.box.find('.total span').text(this.formatCurrency(orderInfo.total))
      this.box.find('.number').text(orderInfo.tickets.length)
      this.box.find('a.details').prop('href', confirmInfo.internal.detailsPath)

      const printer = new TicketPrinter()
      setTimeout(() => {
        printer.printTicketsWithNotification(orderInfo.printable_path)
      }, 2000)
    } else {
      this.box.find('.order-number b').text(orderInfo.number)
      this.trackPiwikGoal(1, orderInfo.total)
    }
  }
}
