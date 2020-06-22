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
      coupons: [],
      exclusiveSeats: false
    }

    this.couponBox = this.box.find('.coupon')
    this.couponField = this.couponBox.find('input[name=code]')
    this.registerEventAndInitiate(this.box.find('select'), 'change', $this => {
      this.choseNumber($this)
    })
    this.couponField.keyup(event => {
      if (event.which === 13) this.addCoupon()
    })
    this.couponBox.find('input[type=submit]').click(() => this.addCoupon())
    this.couponBox.find('.added').on('click', 'a', event => {
      this.removeCoupon($(event.currentTarget).data('index'))
      event.preventDefault()
    })
    this.registerEventAndInitiate(
      this.box.find('tr.ignore_free_tickets input'), 'change', $this => {
        this.info.api.ignore_free_tickets = $this.is(':checked')
        this.updateDiscounts()
      }
    )
    this.box.find('.event-header').on('load', () => this.resizeDelegateBox(true))
  }

  getTypeTotal ($typeBox, number) {
    return $typeBox.data('price') * $typeBox.find('select').val()
  }

  updateSubtotal () {
    this.info.internal.subtotal = 0
    this.info.internal.numberOfTickets = 0
    this.tickets = []
    this.box.find('.number tr').each((_, number) => {
      const $this = $(number)
      if ($this.is('.date_ticketing_ticket_type')) {
        const number = parseInt($this.find('select').val())
        this.info.internal.numberOfTickets += number
        this.info.internal.subtotal += this.getTypeTotal($this)
        for (let i = 0; i < number; i++) {
          this.tickets.push($this.data('price'))
        }
      } else if ($this.is('.subtotal')) {
        togglePluralText(
          $this.find('td').first(), this.info.internal.numberOfTickets
        )
        $this.find('.total span')
          .html(this.formatCurrency(this.info.internal.subtotal))
      }
    })

    this.updateDiscounts()
    this.delegate.updateNextBtn()
  }

  choseNumber ($this) {
    const typeBox = $this.parents('tr')
    const typeId = typeBox.data('id')
    const total = this.formatCurrency(this.getTypeTotal(typeBox))
    typeBox.find('td.total span').html(total)

    this.info.api.tickets[typeId] = parseInt($this.val())
    this.info.internal.ticketTotals[typeId] = total
    this.updateSubtotal()

    this.addBreadcrumb('set ticket number', {
      tickets: this.info.api.tickets
    })
  }

  addCoupon () {
    const code = this.couponBox.find('input[name=code]').val()
    if (this.info.api.couponCodes.indexOf(code) > -1) {
      this.couponError('added')
    } else if (code !== '') {
      this.delegate.toggleModalSpinner(true)

      this.postCouponCode(this.couponBox.data('add-url'), code)
        .then(res => this.couponAdded(res.coupon))
        .catch(res => this.couponError(res.data?.error))
    }
  }

  removeCoupon (index) {
    this.delegate.toggleModalSpinner(true)

    const code = this.info.api.couponCodes[index]
    this.postCouponCode(this.couponBox.data('remove-url'), code)
      .then(res => {
        this.info.internal.coupons.splice(index, 1)
        this.info.api.couponCodes.splice(index, 1)
        this.updateAddedCoupons()
        this.updateCouponResult('', false)
        this.delegate.toggleModalSpinner(false)
      })
      .finally(() => this.delegate.toggleModalSpinner(false))
  }

  postCouponCode (url, code) {
    return fetch(url, 'post', {
      code: code,
      socket_id: this.delegate.getStepInfo('seats').api.socketId
    })
  }

  couponAdded (coupon) {
    let msg = 'Ihr Gutschein wurde erfolgreich hinzugefügt. Weitere Gutscheine sind möglich.'

    this.info.internal.coupons.push(coupon)
    this.info.api.couponCodes.push(this.couponField.val())

    this.updateAddedCoupons()
    this.trackPiwikGoal(2)

    if (coupon.seats) {
      msg += ' Es wurden exklusive Sitzplätze für Sie freigeschaltet.'
    }

    this.couponField.blur().val('')
    this.delegate.toggleModalSpinner(false)
    this.updateCouponResult(msg, false)
    this.resizeDelegateBox()

    this.addBreadcrumb('entered coupon code')
  }

  couponError (error) {
    let msg
    switch (error) {
      case 'expired':
        msg = 'Dieser Code ist leider abgelaufen.'
        break
      case 'added':
        msg = 'Dieser Code wurde bereits zu Ihrer Bestellung hinzugefügt.'
        break
      case 'invalid':
        msg = 'Dieser Code ist nicht gültig.'
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
    this.info.internal.exclusiveSeats = false

    const addedBox = this.couponBox.find('.added')
      .toggle(this.info.api.couponCodes.length > 0)
      .find('td:last-child')
      .empty()

    for (const [i, coupon] of Object.entries(this.info.internal.coupons)) {
      this.info.internal.exclusiveSeats =
        this.info.internal.exclusiveSeats || coupon.seats

      addedBox.append(`<b>${this.info.api.couponCodes[i]}</b> (<a href='#' data-index='${i}'>entfernen</a>)`)
      if (i < this.info.internal.coupons.length - 1) {
        addedBox.append(', ')
      }
    }

    this.updateDiscounts()
  }

  updateDiscounts () {
    const tickets = this.tickets.slice(0).sort(function (a, b) {
      return a - b
    })
    let anyFreeTickets = false
    this.info.internal.total = this.info.internal.subtotal
    this.info.internal.discount = 0

    this.box.find('tr.discount').remove()
    for (const [i, coupon] of Object.entries(this.info.internal.coupons)) {
      if (coupon.free_tickets > 0) {
        anyFreeTickets = true
        let discount = 0

        for (let j = 0; j < coupon.free_tickets; j++) {
          const ticketToRemove = tickets.pop()
          if (ticketToRemove) {
            discount -= ticketToRemove
          }
        }

        if (!this.info.api.ignore_free_tickets) {
          this.info.internal.total += discount
          this.info.internal.discount += discount
        }

        const discountBox = $('<tr>').addClass('discount')
        discountBox.toggleClass('ignore', this.info.api.ignore_free_tickets)
        const info = $('<td>').addClass('plural_text').attr('colspan', 3)
          .html(`Gutschein <em>${this.info.api.couponCodes[i]}</em> (Wert: <span class="number"><span></span></span> Freikarte<span class="plural">n</span>)`)
        discountBox.append(
          info,
          $('<td>').addClass('amount')
            .text(`${this.formatCurrency(discount)} €`)
        )
        discountBox.insertAfter(this.box.find('tr.subtotal'))
        togglePluralText(info, coupon.free_tickets)
      }
    }

    this.box.find('tr.ignore_free_tickets')
      .toggle(anyFreeTickets && this.info.internal.exclusiveSeats)

    const $this = this.box.find('.number tr.total')
    this.info.internal.zeroTotal = this.info.internal.total <= 0
    $this.find('.total span')
      .html(this.formatCurrency(this.info.internal.total))
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
