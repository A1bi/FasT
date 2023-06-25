import Step from './step'
import { togglePluralText, fetch } from '../../utils'
import $ from 'jquery'

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

    this.totalsUrl = this.box.data('totals-url')
    this.couponBox = this.box.find('.coupon')
    this.couponField = this.couponBox.find('input[name=code]')
    this.box.find('select').on('change', () => this.updateNumbers())
    this.updateNumbers()
    this.couponField.keyup(event => {
      if (event.which === 13) this.addCoupon()
    })
    this.couponBox.find('input[type=submit]').click(() => this.addCoupon())
    this.couponBox.find('.added').on('click', 'a', event => {
      this.removeCoupon($(event.currentTarget).data('index'))
      event.preventDefault()
    })
    this.box.find('.event-header').on('load', () => this.resizeDelegateBox())
  }

  getTypeTotal ($typeBox, number) {
    return $typeBox.data('price') * $typeBox.find('select').val()
  }

  async updateSubtotal (toggleSpinner) {
    this.info.internal.numberOfTickets = 0
    this.tickets = []
    this.box.find('.number div').each((_, number) => {
      const $this = $(number)
      if ($this.is('.date_ticketing_ticket_type')) {
        const number = parseInt($this.find('select').val())
        this.info.internal.numberOfTickets += number
        for (let i = 0; i < number; i++) {
          this.tickets.push($this.data('price'))
        }
      } else if ($this.is('.subtotal')) {
        togglePluralText(
          $this, this.info.internal.numberOfTickets
        )
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

      this.box.find('.number .subtotal .total span')
        .html(this.formatCurrency(this.info.internal.subtotal))

      this.updateDiscounts()
      this.delegate.updateNextBtn()
      this.resizeDelegateBox()
    } finally {
      if (toggleSpinner) this.delegate.toggleModalSpinner(false)
    }
  }

  updateNumbers () {
    this.box.find('select').each((_, select) => {
      select = $(select)
      const typeBox = select.parents('.date_ticketing_ticket_type')
      const typeId = typeBox.data('id')
      const total = this.formatCurrency(this.getTypeTotal(typeBox))
      typeBox.find('.total span').html(total)

      this.info.api.tickets[typeId] = parseInt(select.val())
      this.info.internal.ticketTotals[typeId] = total
    })

    this.updateSubtotal()

    this.addBreadcrumb('set ticket number', {
      tickets: this.info.api.tickets
    })
  }

  async addCoupon () {
    const code = this.couponBox.find('input[name=code]').val()
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

    this.couponField.blur().val('')
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
    this.couponBox.find('.msg').text(msg).toggle(error).toggleClass('text-red', error)
    this.resizeDelegateBox()
  }

  updateAddedCoupons () {
    const addedBox = this.couponBox.find('.added')
      .toggle(this.info.api.couponCodes.length > 0)
      .find('span')
      .empty()

    this.info.api.couponCodes.forEach((code, i) => {
      addedBox.append(`<b>${code}</b> (<a href='#' data-index='${i}'>entfernen</a>)`)
      if (i < this.info.api.couponCodes.length - 1) {
        addedBox.append(', ')
      }
    })
  }

  updateDiscounts () {
    this.updateDiscountRow('free_tickets', this.info.internal.freeTicketsDiscount)
    this.updateDiscountRow('credit', this.info.internal.creditDiscount)

    this.info.internal.zeroTotal = this.info.internal.totalAfterCoupons <= 0
    this.box.find('.number .total .total span')
      .html(this.formatCurrency(this.info.internal.totalAfterCoupons))
  }

  updateDiscountRow (klass, discount) {
    this.box.find(`.discount.${klass}`)
      .toggle(discount < 0)
      .find('.amount').text(`${this.formatCurrency(discount)} €`)
  }

  nextBtnEnabled () {
    return this.info.internal.numberOfTickets > 0
  }

  validate () {
    if (this.couponField.val() !== '') {
      this.addCoupon()
      return false
    }
    return true
  }
}
