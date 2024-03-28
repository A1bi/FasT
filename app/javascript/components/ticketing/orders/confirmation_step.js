import Step from 'components/ticketing/orders/step'
import { toggleDisplay, togglePluralText, fetch } from 'components/utils'

export default class extends Step {
  constructor (delegate) {
    super('confirm', delegate)

    this.couponTemplate = this.box.querySelector('tr.coupon')
    if (this.couponTemplate) this.couponTemplate.remove()
  }

  updateCouponSummary () {
    const couponsInfo = this.delegate.getStepInfo('coupons')
    if (!couponsInfo) return

    this.box.querySelectorAll(':scope tr.coupon').forEach(el => el.remove())
    let total = 0
    let totalNumber = 0

    couponsInfo.api.coupons.forEach(coupon => {
      const row = this.couponTemplate.cloneNode(true)
      const couponTotal = coupon.number * coupon.value
      const numberText = row.querySelector('.plural_text')

      togglePluralText(numberText, coupon.number)
      numberText.querySelector('.value').textContent = this.formatCurrency(coupon.value)
      row.querySelector('.total span').textContent = this.formatCurrency(couponTotal)

      this.box.querySelector('.coupons tbody').prepend(row)
      total += couponTotal
      totalNumber += coupon.number
    })

    togglePluralText(this.box.querySelector('tr.total .plural_text'), totalNumber)
    this.box.querySelector('tr.total td.total span').textContent = this.formatCurrency(total)
  }

  updateTicketSummary () {
    const ticketsInfo = this.delegate.getStepInfo('tickets')
    if (!ticketsInfo) return

    this.box.querySelector('.date').textContent = this.delegate.getStepInfo('seats').internal.localizedDate

    this.box.querySelectorAll(':scope .tickets tbody tr').forEach(typeBox => {
      let number, total
      if (typeBox.matches('.subtotal')) {
        number = ticketsInfo.internal.numberOfTickets
        total = this.formatCurrency(ticketsInfo.internal.subtotal)
      } else if (typeBox.matches('.discount')) {
        toggleDisplay(typeBox, ticketsInfo.internal.discount !== 0)
        total = this.formatCurrency(ticketsInfo.internal.discount)
      } else if (typeBox.matches('.total')) {
        total = this.formatCurrency(ticketsInfo.internal.totalAfterCoupons)
      } else {
        const typeId = typeBox.querySelector('td').dataset.id
        number = ticketsInfo.api.tickets[typeId]
        toggleDisplay(typeBox, number > 0)
        total = ticketsInfo.internal.ticketTotals[typeId]
      }
      typeBox.querySelector('.total span').textContent = total

      const single = typeBox.querySelector('.single')
      if (!single) return
      if (typeBox.matches('.subtotal')) {
        togglePluralText(single, number)
      } else {
        if (number === 0) number = 'keine'
        single.querySelector('.number').textContent = number
      }
    })
  }

  willMoveIn () {
    const ticketsInternal = this.delegate.getStepInfo('tickets')?.internal

    let btnText = 'bestätigen'
    if (this.delegate.web && !ticketsInternal?.zeroTotal) {
      btnText = 'kostenpflichtig bestellen'
    }
    this.delegate.setNextBtnText(btnText)

    this.updateTicketSummary()
    this.updateCouponSummary()

    for (const type of ['address', 'payment']) {
      const info = this.delegate.getStepInfo(type)
      if (!info) continue
      const box = this.box.querySelector(`.${type}`)
      if (type === 'payment' && !ticketsInternal?.zeroTotal) {
        box.classList.remove('transfer', 'charge', 'box_office', 'cash')
        box.classList.add(info.api.method)
      }
      for (const [key, value] of Object.entries(info.api)) {
        const additionalInfoBox = box.querySelector(`.${key}`)
        if (additionalInfoBox) additionalInfoBox.textContent = value
      }
    }
  }

  validate () {
    return this.validateFields(() => {}, () => {
      this.info.api.newsletter = this.info.api.newsletter === '1'
    })
  }

  validateAsync (callback) {
    this.delegate.toggleModalSpinner(true)
    this.placeOrder(callback)
  }

  placeOrder (successCallback) {
    this.delegate.hideOrderControls()

    const apiInfo = this.delegate.getApiInfo()

    const orderInfo = {
      date: apiInfo.seats?.date,
      tickets: apiInfo.tickets?.tickets,
      coupons: apiInfo.coupons?.coupons,
      address: apiInfo.address,
      payment: apiInfo.payment,
      coupon_codes: apiInfo.tickets?.couponCodes
    }

    const info = {
      order: orderInfo,
      type: this.delegate.type,
      socket_id: apiInfo.seats?.socketId,
      newsletter: apiInfo.confirm.newsletter
    }

    fetch('/api/ticketing/orders', 'post', info)
      .then(res => this.orderPlaced(res, successCallback))
      .catch(res => this.orderFailed())
  }

  disconnect () {
    const chooser = this.delegate.getStep('seats')?.chooser
    if (chooser) chooser.disconnect()
    this.delegate.killExpirationTimer()
  }

  orderFailed () {
    this.disconnect()
    this.delegate.showModalAlert('Leider ist ein Fehler aufgetreten.<br />Ihre Bestellung konnte nicht aufgenommen werden.')
  }

  orderPlaced (response, callback) {
    this.disconnect()
    this.delegate.toggleModalSpinner(false)

    this.info.internal.order = response

    if (this.delegate.stepBox.dataset.orderPath) {
      this.info.internal.detailsPath = this.delegate.stepBox.dataset.orderPath
        .replace(':id', this.info.internal.order.id)

      if (this.delegate.admin) {
        window.location = this.info.internal.detailsPath
        return
      }
    }

    callback()
  }
}
