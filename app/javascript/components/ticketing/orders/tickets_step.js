import Step from 'components/ticketing/orders/step'
import { toggleDisplay, togglePluralText, fetch } from 'components/utils'

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

  getTypeTotal (typeBox, number) {
    return typeBox.dataset.price * typeBox.querySelector('select').value
  }

  async updateSubtotal (toggleSpinner) {
    this.info.internal.numberOfTickets = 0
    this.tickets = []
    this.box.querySelectorAll(':scope .number div').forEach(numberBox => {
      if (numberBox.matches('.date_ticketing_ticket_type')) {
        const number = parseInt(numberBox.querySelector('select').value)
        this.info.internal.numberOfTickets += number
        for (let i = 0; i < number; i++) {
          this.tickets.push(numberBox.dataset.price)
        }
      } else if (numberBox.matches('.subtotal')) {
        togglePluralText(numberBox, this.info.internal.numberOfTickets)
      }
    })

    if (toggleSpinner) this.delegate.toggleModalSpinner(true)

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
        totalAfterCoupons: res.total_after_coupons,
        freeTicketsDiscount: res.free_tickets_discount,
        creditDiscount: res.credit_discount,
        discount: res.free_tickets_discount + res.credit_discount
      }

      this.box.querySelector('.number .subtotal .total span')
        .textContent = this.formatCurrency(this.info.internal.subtotal)

      this.updateDiscounts()
      this.delegate.updateNextBtn()
    } finally {
      if (toggleSpinner) this.delegate.toggleModalSpinner(false)
    }
  }

  updateNumbers () {
    this.box.querySelectorAll(':scope select').forEach(select => {
      const typeBox = select.closest('.date_ticketing_ticket_type')
      const typeId = typeBox.dataset.id
      const total = this.formatCurrency(this.getTypeTotal(typeBox))
      typeBox.querySelector('.total span').textContent = total

      this.info.api.tickets[typeId] = parseInt(select.value)
      this.info.internal.ticketTotals[typeId] = total
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

    this.info.internal.zeroTotal = this.info.internal.totalAfterCoupons <= 0
    this.box.querySelector('.number .total .total span')
      .textContent = this.formatCurrency(this.info.internal.totalAfterCoupons)
  }

  updateDiscountRow (klass, discount) {
    const row = this.box.querySelector(`.discount.${klass}`)
    toggleDisplay(row, discount < 0)
    row.querySelector('.amount').textContent = `${this.formatCurrency(discount)} €`
  }

  nextBtnEnabled () {
    return this.info.internal.numberOfTickets > 0
  }

  validate () {
    if (this.couponField.value !== '') {
      this.addCoupon()
      return false
    }
    return true
  }
}
