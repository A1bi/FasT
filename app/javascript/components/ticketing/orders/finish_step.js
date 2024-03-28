import Step from 'components/ticketing/orders/step'
import { toggleDisplay } from 'components/utils'

export default class extends Step {
  constructor (delegate) {
    super('finish', delegate)

    this.orderNumber = this.box.querySelector('.order-number')
    this.toggleOrderNumber(false)
  }

  willMoveIn () {
    const payInfo = this.delegate.getStepInfo('payment')
    if (payInfo) {
      toggleDisplay(this.box.querySelector('.items'), payInfo.api.method === 'charge')
    }

    const confirmInfo = this.delegate.getStepInfo('confirm')
    const orderInfo = confirmInfo.internal.order
    orderInfo.total = Number.parseFloat(orderInfo.total)

    if (this.delegate.retail) {
      this.box.querySelector('.total span').textContent = this.formatCurrency(orderInfo.total)
      this.box.querySelector('.number').textContent = orderInfo.tickets.length
      this.box.querySelector('a.details').href = confirmInfo.internal.detailsPath

      const event = new CustomEvent('_ticketing--orders-finish:printTickets', {
        detail: { path: orderInfo.printable_path }
      })
      window.dispatchEvent(event)
    } else {
      this.box.querySelector('.order-number b').textContent = orderInfo.number
      this.trackPiwikGoal(1, orderInfo.total)
    }

    // only show now to activate animation
    this.toggleOrderNumber(true)
  }

  toggleOrderNumber (toggle) {
    if (this.orderNumber) toggleDisplay(this.orderNumber, toggle)
  }
}
