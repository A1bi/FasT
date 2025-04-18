import Step from 'components/ticketing/orders/step'
import { toggleDisplayIfExists } from 'components/utils'

export default class extends Step {
  constructor (delegate) {
    super('payment', delegate)

    this.box.querySelectorAll(':scope [name=method]').forEach(radio => {
      radio.addEventListener('change', () => {
        if (!radio.checked) return
        this.info.api.method = radio.value
        const chargeDataBox = this.box.querySelector('.charge_data')
        this.slideToggle(chargeDataBox, this.methodIsCharge)
        chargeDataBox.querySelectorAll(':scope input').forEach(el => { el.disabled = !this.methodIsCharge })
        this.delegate.updateBtns()
      })
    })
  }

  willMoveIn () {
    if (this.delegate.web) {
      const boxOffice = this.delegate.getStepInfo('seats')?.internal.boxOfficePayment
      this.togglePaymentMethod('transfer', !boxOffice)
      this.togglePaymentMethod('box_office', boxOffice)

      if (!boxOffice && this.info.api.method === 'box_office') {
        this.info.api.method = null
      }
    }

    Object.values(this.delegate.constructor.stripePaymentMethods).forEach(method => {
      this.togglePaymentMethod(method, method === this.delegate.availableStripePaymentMethod)
    })
  }

  togglePaymentMethod (method, toggle) {
    toggleDisplayIfExists(this.box.querySelector(`.${method}`), toggle)
  }

  get methodIsCharge () {
    return this.info.api.method === 'charge'
  }

  nextBtnEnabled () {
    return !!this.info.api.method
  }

  shouldBeSkipped () {
    return !this.delegate.paymentRequired
  }
}
