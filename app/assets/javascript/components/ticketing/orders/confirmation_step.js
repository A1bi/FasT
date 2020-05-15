import Step from './step'
import { togglePluralText, fetch } from '../../utils'
import $ from 'jquery'

export default class extends Step {
  constructor (delegate) {
    super('confirm', delegate)
  }

  updateSummary (info, part) {
    for (const [key, value] of Object.entries(info)) {
      this.box.find(`.${part} .${key}`).text(value)
    }
  }

  willMoveIn () {
    let btnText = 'bestätigen'
    if (this.delegate.web &&
        !this.delegate.getStepInfo('tickets').internal.zeroTotal) {
      btnText = 'kostenpflichtig bestellen'
    }
    this.delegate.setNextBtnText(btnText)

    const ticketsInfo = this.delegate.getStepInfo('tickets')
    this.box.find('.date').text(
      this.delegate.getStepInfo('seats').internal.localizedDate
    )

    this.box.find('.tickets tbody tr').show().each((_, element) => {
      const typeBox = $(element)
      let number, total
      if (typeBox.is('.subtotal')) {
        number = ticketsInfo.internal.numberOfTickets
        total = this.formatCurrency(ticketsInfo.internal.subtotal)
      } else if (typeBox.is('.discount')) {
        if (ticketsInfo.internal.discount === 0) {
          typeBox.hide()
          return
        }
        total = this.formatCurrency(ticketsInfo.internal.discount)
      } else if (typeBox.is('.total')) {
        total = this.formatCurrency(ticketsInfo.internal.total)
      } else {
        const typeId = typeBox.find('td').first().data('id')
        number = ticketsInfo.api.tickets[typeId]
        if (!number || number < 1) {
          typeBox.hide()
          return
        }
        total = ticketsInfo.internal.ticketTotals[typeId]
      }
      typeBox.find('.total span').text(total)
      const single = typeBox.find('.single')
      if (typeBox.is('.subtotal')) {
        togglePluralText(single, number)
      } else {
        if (number === 0) number = 'keine'
        single.find('.number').text(number)
      }
    })

    for (const type of ['address', 'payment']) {
      const info = this.delegate.getStepInfo(type)
      if (!info) continue
      const box = this.box.find(`.${type}`)
      if (type === 'payment' && !ticketsInfo.internal.zeroTotal) {
        box.removeClass('transfer charge box_office').addClass(info.api.method)
      }
      for (const [key, value] of Object.entries(info.api)) {
        box.find(`.${key}`).text(value)
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
      date: apiInfo.seats.date,
      tickets: apiInfo.tickets.tickets,
      ignore_free_tickets: apiInfo.tickets.ignore_free_tickets,
      address: apiInfo.address,
      payment: apiInfo.payment,
      coupon_codes: apiInfo.tickets.couponCodes
    }

    const info = {
      order: orderInfo,
      type: this.delegate.type,
      socket_id: apiInfo.seats.socketId,
      newsletter: apiInfo.confirm.newsletter
    }

    fetch('/api/ticketing/orders', 'post', info)
      .then(res => this.orderPlaced(res, successCallback))
      .catch(res => this.orderFailed())
  }

  disconnect () {
    const chooser = this.delegate.getStep('seats').chooser
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
    this.info.internal.detailsPath =
      this.delegate.stepBox.data('order-path')
        .replace(':id', this.info.internal.order.id)

    if (this.delegate.admin) {
      window.location = this.info.internal.detailsPath
      return
    }

    callback()
  }
}
