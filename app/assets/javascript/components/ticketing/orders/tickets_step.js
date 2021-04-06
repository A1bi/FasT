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
    this.box.find('.event-header').on('load', () => this.resizeDelegateBox(true))
  }

  getTypeTotal ($typeBox, number) {
    return $typeBox.data('price') * $typeBox.find('select').val()
  }

  updateSubtotal () {
    this.info.internal.numberOfTickets = 0
    this.tickets = []
    this.box.find('.number tr').each((_, number) => {
      const $this = $(number)
      if ($this.is('.date_ticketing_ticket_type')) {
        const number = parseInt($this.find('select').val())
        this.info.internal.numberOfTickets += number
        for (let i = 0; i < number; i++) {
          this.tickets.push($this.data('price'))
        }
      } else if ($this.is('.subtotal')) {
        togglePluralText(
          $this.find('td').first(), this.info.internal.numberOfTickets
        )
      }
    })

    return fetch(this.totalsUrl, 'post', {
      event_id: this.delegate.eventId,
      tickets: this.info.api.tickets,
      coupon_codes: this.info.api.couponCodes
    }).then(res => {
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

      this.box.find('.number tr.subtotal .total span')
        .html(this.formatCurrency(this.info.internal.subtotal))

      this.updateDiscounts()
      this.delegate.updateNextBtn()
    })
  }

  updateNumbers () {
    this.box.find('select').each((_, select) => {
      select = $(select)
      const typeBox = select.parents('tr')
      const typeId = typeBox.data('id')
      const total = this.formatCurrency(this.getTypeTotal(typeBox))
      typeBox.find('td.total span').html(total)

      this.info.api.tickets[typeId] = parseInt(select.val())
      this.info.internal.ticketTotals[typeId] = total
    })

    this.updateSubtotal()

    this.addBreadcrumb('set ticket number', {
      tickets: this.info.api.tickets
    })
  }

  addCoupon () {
    this.delegate.toggleModalSpinner(true)

    const code = this.couponBox.find('input[name=code]').val()
    if (this.info.api.couponCodes.indexOf(code) > -1) {
      this.couponError('added')
    } else if (code !== '') {
      this.info.api.couponCodes.push(code)

      this.updateSubtotal()
        .then(result => {
          if (this.info.api.couponCodes.indexOf(code) > -1) {
            this.couponAdded()
          } else {
            this.couponError('invalid')
          }
        })
        .finally(() => this.delegate.toggleModalSpinner(false))
    }
  }

  removeCoupon (index) {
    this.delegate.toggleModalSpinner(true)

    this.info.api.couponCodes.splice(index, 1)

    this.updateSubtotal()
      .then(() => {
        this.updateAddedCoupons()
        this.updateCouponResult('', false)
      })
      .finally(() => this.delegate.toggleModalSpinner(false))
  }

  couponAdded () {
    const msg = 'Ihr Gutschein wurde erfolgreich hinzugefügt. Weitere Gutscheine sind möglich.'

    this.updateAddedCoupons()
    this.trackPiwikGoal(2)

    this.couponField.blur().val('')
    this.delegate.toggleModalSpinner(false)
    this.updateCouponResult(msg, false)
    this.resizeDelegateBox()

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

    this.delegate.toggleModalSpinner(false)
    this.updateCouponResult(msg, true)
    this.resizeDelegateBox()
  }

  updateCouponResult (msg, error) {
    this.couponBox.find('.msg .result')
      .text(msg).toggleClass('error', error).parent().toggle(!!msg)
  }

  updateAddedCoupons () {
    const addedBox = this.couponBox.find('.added')
      .toggle(this.info.api.couponCodes.length > 0)
      .find('td:last-child')
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
    this.box.find('.number tr.total .total span')
      .html(this.formatCurrency(this.info.internal.totalAfterCoupons))
  }

  updateDiscountRow (klass, discount) {
    this.box.find(`tr.discount.${klass}`)
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
