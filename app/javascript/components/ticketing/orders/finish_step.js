import Step from 'components/ticketing/orders/step'

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

      const event = new CustomEvent('_ticketing--orders-finish:printTickets', {
        detail: { path: orderInfo.printable_path }
      })
      window.dispatchEvent(event)
    } else {
      this.box.find('.order-number b').text(orderInfo.number)
      this.trackPiwikGoal(1, orderInfo.total)
    }
  }
}
