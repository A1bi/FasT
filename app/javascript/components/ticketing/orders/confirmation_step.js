import Step from 'components/ticketing/orders/step'
import { toggleDisplay, togglePluralText } from 'components/utils'

export default class extends Step {
  constructor (delegate) {
    super('confirm', delegate)

    this.lineItemTemplate = this.box.querySelector('.line-item')
    this.lineItemTemplate.remove()
  }

  updateLineItems () {
    this.box.querySelectorAll(':scope .line-item').forEach(el => el.remove())

    this.delegate.lineItems.forEach(lineItem => {
      const row = this.lineItemTemplate.cloneNode(true)

      row.querySelector('.label').textContent = lineItem.label
      row.querySelector('.price').textContent = this.formatCurrency(lineItem.price)
      row.querySelector('.number').textContent = lineItem.number
      row.querySelector('.total').textContent = this.formatCurrency(lineItem.total)

      this.box.querySelector('.summary tbody').prepend(row)
    })
  }

  updateCouponSummary () {
    if (!this.delegate.getStepInfo('coupons')) return

    togglePluralText(this.box.querySelector('tr.total .plural_text'), this.delegate.numberOfArticles)
    this.box.querySelector('tr.total td.total').textContent = this.formatCurrency(this.delegate.orderTotal)
  }

  updateTicketSummary () {
    const ticketsInfo = this.delegate.getStepInfo('tickets')
    if (!ticketsInfo) return

    this.box.querySelector('.date').textContent = this.delegate.getStepInfo('seats').internal.localizedDate

    this.box.querySelectorAll(':scope .summary tr:not(.line-item)').forEach(typeBox => {
      let total
      const single = typeBox.querySelector('.single')
      if (typeBox.matches('.subtotal')) {
        togglePluralText(single, this.delegate.numberOfArticles)
        total = this.formatCurrency(ticketsInfo.internal.subtotal)
      } else if (typeBox.matches('.discount')) {
        toggleDisplay(typeBox, this.delegate.orderDiscount !== 0)
        total = this.formatCurrency(this.delegate.orderDiscount)
      } else if (typeBox.matches('.total')) {
        total = this.formatCurrency(this.delegate.orderTotal)
      }
      typeBox.querySelector('.total').textContent = total
    })
  }

  willMoveIn () {
    let btnText = 'bestätigen'
    if (this.delegate.web && this.delegate.paymentRequired) {
      btnText = 'kostenpflichtig bestellen'
    }
    this.delegate.setNextBtnText(btnText)

    this.updateLineItems()
    this.updateTicketSummary()
    this.updateCouponSummary()

    for (const type of ['address', 'payment']) {
      const info = this.delegate.getStepInfo(type)
      if (!info) continue
      const box = this.box.querySelector(`.${type}`)
      if (type === 'payment' && this.delegate.paymentRequired) {
        box.classList.remove('transfer', 'charge', 'box_office', 'cash')
        box.classList.add(info.api.method)
      }
      for (const [key, value] of Object.entries(info.api)) {
        const additionalInfoBox = box.querySelector(`.${key}`)
        if (additionalInfoBox) additionalInfoBox.textContent = value
      }
    }
  }

  updateInfoFromFields () {
    super.updateInfoFromFields()

    this.info.api.newsletter = this.info.api.newsletter === '1'
  }

  get finalizesOrder () {
    return true
  }
}
