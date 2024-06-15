import Step from 'components/ticketing/orders/step'
import { toggleDisplay, toggleDisplayIfExists } from 'components/utils'

export default class extends Step {
  constructor (delegate) {
    super('finish', delegate)
    if (!this.box) return

    this.orderNumber = this.box.querySelector('.order-number')
    this.toggleOrderNumber(false)
  }

  willMoveIn () {
    const payInfo = this.delegate.getStepInfo('payment')
    if (payInfo) {
      toggleDisplay(this.box.querySelector('.items'), payInfo.api.method === 'charge')
    }

    if (this.delegate.retail) {
      this.box.querySelector('.total').textContent = this.formatCurrency(this.delegate.placedOrder.total)
      this.box.querySelector('.number').textContent = this.delegate.placedOrder.tickets.length
      this.box.querySelector('a.details').href = this.delegate.orderDetailsPath

      const event = new CustomEvent('_ticketing--orders-finish:printTickets', {
        detail: { path: this.delegate.placedOrder.printable_path }
      })
      window.dispatchEvent(event)
    } else {
      this.box.querySelector('.order-number b').textContent = this.delegate.placedOrder.number
      this.trackPiwikGoal(1, this.delegate.placedOrder.total)
    }

    // only show now to activate animation
    this.toggleOrderNumber(true)
  }

  toggleOrderNumber (toggle) {
    toggleDisplayIfExists(this.orderNumber, toggle)
  }
}
