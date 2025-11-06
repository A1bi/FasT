import Step from 'components/ticketing/orders/step'
import { toggleDisplay, togglePluralText, fetch, formatCurrency } from 'components/utils'

export default class extends Step {
  constructor (delegate) {
    super('tickets', delegate)

    this.info.api = {
      couponCodes: [],
      tickets: {}
    }

    this.info.internal = {
      ticketTotals: {},
      coupons: []
    }

    this.totalsUrl = this.box.dataset.totalsUrl
    this.couponBox = this.box.querySelector('.coupon')
    this.couponField = this.couponBox.querySelector('input[name=code]')
    this.box.querySelectorAll(':scope select').forEach(el => {
      el.addEventListener('change', () => this.updateNumbers())
    })
    this.updateNumbers()
    this.couponField.addEventListener('keyup', event => {
      if (event.code === 'Enter') this.addCoupon()
    })
    this.couponBox.querySelector('input[type=submit]').addEventListener('click', () => this.addCoupon())
    this.couponBox.querySelector(':scope .added').addEventListener('click', event => {
      if (event.target.tagName !== 'A') return
      this.removeCoupon(event.target.dataset.index)
      event.preventDefault()
    })
  }

  async updateSubtotal (toggleSpinner) {
    this.tickets = []
    this.box.querySelectorAll(':scope .number div').forEach(numberBox => {
      if (numberBox.matches('.date_ticketing_ticket_type')) {
        const number = parseInt(numberBox.querySelector('select').value)
        for (let i = 0; i < number; i++) {
          this.tickets.push(numberBox.dataset.price)
        }
      } else if (numberBox.matches('.subtotal')) {
        togglePluralText(numberBox, this.delegate.numberOfArticles)
      }
    })

    if (toggleSpinner) this.delegate.toggleModalBox(true)

    try {
      const res = await fetch(this.totalsUrl, 'post', {
        event_id: this.delegate.eventId,
        tickets: this.info.api.tickets,
        coupon_codes: this.info.api.couponCodes,
        socket_id: this.delegate.getApiInfo().seats?.socketId
      })

      this.info.api.couponCodes = res.redeemed_coupons
      this.info.internal = {
        ...this.info.internal,
        subtotal: res.subtotal,
        total: res.total,
        freeTicketsDiscount: res.free_tickets_discount,
        creditDiscount: res.credit_discount
      }

      this.delegate.orderTotal = res.total_after_coupons
      this.delegate.orderDiscount = res.free_tickets_discount + res.credit_discount

      this.box.querySelector('.number .subtotal .total')
        .textContent = formatCurrency(this.info.internal.subtotal)

      this.updateDiscounts()
      this.delegate.updateBtns()
    } finally {
      if (toggleSpinner) this.delegate.toggleModalBox(false)
    }
  }

  updateNumbers () {
    this.delegate.clearLineItems()

    this.box.querySelectorAll(':scope select').forEach(select => {
      const typeBox = select.closest('.date_ticketing_ticket_type')
      const typeId = typeBox.dataset.id
      const label = typeBox.querySelector('label').textContent
      const price = parseFloat(typeBox.dataset.price)
      const number = parseInt(select.value)
      const lineItem = this.delegate.addLineItem(label, price, number)

      typeBox.querySelector('.total').textContent = formatCurrency(lineItem.total)
      this.info.api.tickets[typeId] = number
    })

    this.updateSubtotal()

    this.addBreadcrumb('set ticket number', {
      tickets: this.info.api.tickets
    })
  }

  async addCoupon () {
    const code = this.couponBox.querySelector('input[name=code]').value
    if (this.info.api.couponCodes.indexOf(code) > -1) {
      this.couponError('added')
    } else if (code !== '') {
      this.info.api.couponCodes.push(code)

      try {
        await this.updateSubtotal(true)
        if (this.info.api.couponCodes.indexOf(code) > -1) {
          this.couponAdded()
        } else {
          this.couponError('invalid')
        }
      } catch {
        this.couponError()
      }
    }
  }

  async removeCoupon (index) {
    this.info.api.couponCodes.splice(index, 1)

    await this.updateSubtotal(true)
    this.updateAddedCoupons()
    this.updateCouponResult('', false)
  }

  couponAdded () {
    const msg = 'Ihr Gutschein wurde erfolgreich hinzugefügt. Weitere Gutscheine sind möglich.'

    this.updateAddedCoupons()
    this.trackPiwikGoal(2)

    this.couponField.blur()
    this.couponField.value = ''
    this.updateCouponResult(msg, false)

    this.addBreadcrumb('entered coupon code')
  }

  couponError (error) {
    let msg
    switch (error) {
      case 'invalid':
        msg = 'Dieser Gutscheincode ist ungültig oder bereits abgelaufen.'
        break
      case 'added':
        msg = 'Dieser Gutscheincode wurde bereits zu Ihrer Bestellung hinzugefügt.'
        break
      default:
        msg = 'Es ist ein unbekannter Fehler aufgetreten.'
    }

    this.updateCouponResult(msg, true)
  }

  updateCouponResult (msg, error) {
    const msgBox = this.couponBox.querySelector('.msg')
    msgBox.textContent = msg
    msgBox.classList.toggle('text-red', error)
    toggleDisplay(msgBox, !!msg)
  }

  updateAddedCoupons () {
    const addedBox = this.couponBox.querySelector('.added')
    toggleDisplay(addedBox, this.info.api.couponCodes.length > 0)
    const list = addedBox.querySelector('span')
    list.replaceChildren()

    this.info.api.couponCodes.forEach((code, i) => {
      list.innerHTML += `<b>${code}</b> (<a href='#' data-index='${i}'>entfernen</a>)`
      if (i < this.info.api.couponCodes.length - 1) {
        list.innerHTML += ', '
      }
    })
  }

  updateDiscounts () {
    this.updateDiscountRow('free_tickets', this.info.internal.freeTicketsDiscount)
    this.updateDiscountRow('credit', this.info.internal.creditDiscount)

    this.box.querySelector('.number .total .total')
      .textContent = formatCurrency(this.delegate.orderTotal)
  }

  updateDiscountRow (klass, discount) {
    const row = this.box.querySelector(`.discount.${klass}`)
    toggleDisplay(row, discount < 0)
    row.querySelector('.amount').textContent = formatCurrency(discount)
  }

  nextBtnEnabled () {
    return this.delegate.numberOfArticles > 0
  }

  validate () {
    if (this.couponField.value !== '') {
      this.addCoupon()
      return false
    }
    return true
  }
}
