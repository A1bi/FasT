/* global _paq */

import $ from 'jquery'
import { addBreadcrumb } from '@sentry/browser'
import SeatChooser from '../../components/ticketing/seat_chooser'
import { togglePluralText } from '../../components/utils'

function Step (name, delegate) {
  this.name = name
  this.box = $(`.stepCon.${this.name}`)
  this.info = { api: {}, internal: {} }
  this.delegate = delegate
}

Step.prototype = {
  moveIn: function (animate) {
    this.delegate.setNextBtnText()
    this.willMoveIn()

    animate = animate !== false

    this.box.show()
    const props = { left: '0%' }
    if (animate) {
      this.box.animate(props, this.didMoveIn)
    } else {
      this.box.css(props)
      this.didMoveIn()
    }
    this.resizeDelegateBox(animate)
  },

  moveOut: function (left) {
    this.box.animate({ left: 100 * ((left) ? -1 : 1) + '%' }, box => {
      $(box).hide()
    })
  },

  resizeDelegateBox: function (animated) {
    if (this.box.is(':visible')) {
      this.delegate.resizeStepBox(this.box.outerHeight(true), animated)
    }
  },

  slideToggle: function (obj, toggle) {
    const props = {
      step: () => this.resizeDelegateBox(false)
    }

    if (toggle) {
      obj.slideDown(props)
    } else {
      obj.slideUp(props)
    }

    return obj
  },

  updateInfoFromFields: function () {
    const fields = this.box.find('form').serializeArray()
    for (const field of fields) {
      const name = field.name.match(/\[([a-z_]+)\]/)
      if (!!name && !/_confirmation$/.test(name[1])) {
        if (name[1] === 'affiliation' && ['Herr', 'Frau'].indexOf(field.value) > -1) {
          field.value = ''
        }
        this.info.api[name[1]] = field.value
      }
    }
  },

  getStepInfo: function (stepName) {
    return this.delegate.info[stepName].internal
  },

  getFieldWithKey: function (key) {
    return this.box.find(`#${this.name}_${key}`)
  },

  validate: function () {
    return true
  },

  validateAsync: function (callback) {
    callback()
  },

  validateField: function (key, error, validationProc) {
    const field = this.getFieldWithKey(key)
    if (!validationProc(field)) {
      this.showErrorOnField(key, error)
    }
  },

  validateFields: function (beforeProc, afterProc) {
    this.box.find('tr').removeClass('error')
    this.foundErrors = false
    beforeProc()

    if (this.foundErrors) {
      this.resizeDelegateBox(true)
    } else {
      this.updateInfoFromFields()
    }
    if (afterProc) afterProc()

    return !this.foundErrors
  },

  upperStrip: function (value) {
    return value.toUpperCase().replace(/ /g, '')
  },

  valueNotEmpty: function (value) {
    return !value.match(/^[\s\t\r\n]*$/)
  },

  valueOnlyDigits: function (value) {
    return value.match(/^\d*$/)
  },

  valueIsIBAN: function (value) {
    const parts = this.upperStrip(value)
      .match(/^([A-Z]{2})(\d{2})([A-Z0-9]{6,30})$/)

    if (parts) {
      const country = parts[1]
      const check = parts[2]
      const bban = parts[3]
      let number = bban + country + check

      number = number.replace(/\D/g, char => {
        return char.charCodeAt(0) - 64 + 9
      })

      let remainder = 0
      for (let i = 0; i < number.length; i++) {
        remainder = (remainder + number.charAt(i)) % 97
      }

      if ((country === 'DE' && bban.length !== 18) || remainder !== 1) {
        return false
      }
    } else {
      return false
    }

    return true
  },

  fieldIsEmail: function (field) {
    return field.val().match(field.attr('pattern'))
  },

  showErrorOnField: function (key, msg) {
    const input = this.getFieldWithKey(key)
    const field = input.parents('tr').addClass('error')
    if (msg) field.find('.msg').html(msg)
    this.foundErrors = true

    this.addBreadcrumb('form error', {
      field: key,
      value: input.val(),
      message: msg
    }, 'warn')
  },

  willMoveIn: function () {},

  didMoveIn: function () {},

  shouldBeSkipped: function () {
    return false
  },

  nextBtnEnabled: function () {
    return true
  },

  formatCurrency: function (value) {
    return value.toFixed(2).toString().replace('.', ',')
  },

  trackPiwikGoal: function (id, revenue) {
    try {
      _paq.push(['trackGoal', id, revenue])
    } catch (e) {}
  },

  addBreadcrumb: function (message, data, level) {
    addBreadcrumb({
      category: `ordering.${this.name}`,
      message: message,
      data: data,
      level: level
    })
  },

  registerEventAndInitiate: function (elements, event, proc) {
    elements.on(event, event => proc($(event.currentTarget)))
    for (const element of elements) proc($(element))
  }
}

function TicketsStep (delegate) {
  Step.call(this, 'tickets', delegate)

  this.info.api = {
    couponCodes: [],
    tickets: {}
  }
  this.info.internal = {
    ticketTotals: {},
    coupons: [],
    exclusiveSeats: false
  }

  this.getTypeTotal = function ($typeBox, number) {
    return $typeBox.data('price') * $typeBox.find('select').val()
  }

  this.updateSubtotal = function () {
    this.info.internal.subtotal = 0
    this.info.internal.numberOfTickets = 0
    this.tickets = []
    for (const number of this.box.find('.number tr')) {
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
    }

    this.updateDiscounts()
    this.delegate.updateNextBtn()
  }

  this.choseNumber = function ($this) {
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

  this.addCoupon = function () {
    const code = this.couponBox.find('input[name=code]').val()
    if (this.info.api.couponCodes.indexOf(code) > -1) {
      this.couponAdded({ ok: false, error: 'added' })
    } else if (code !== '') {
      this.delegate.toggleModalSpinner(true)
      $.post(this.couponBox.data('add-url'), {
        code: code,
        socketId: this.delegate.getStepInfo('seats').api.socketId
      }).always(res => this.couponAdded(res))
    }
  }

  this.removeCoupon = function (index) {
    const code = this.info.api.couponCodes[index]

    this.delegate.toggleModalSpinner(true)
    $.post(this.couponBox.data('remove-url'), {
      code: code,
      socketId: this.delegate.getStepInfo('seats').api.socketId
    }).always(res => {
      if (res.ok) {
        this.info.internal.coupons.splice(index, 1)
        this.info.api.couponCodes.splice(index, 1)
        this.updateAddedCoupons()
        this.updateCouponResult('', false)
      }
      this.delegate.toggleModalSpinner(false)
    })
  }

  this.couponAdded = function (res) {
    let msg = 'Ihr Gutschein wurde erfolgreich hinzugefügt. Weitere Gutscheine sind möglich.'
    if (res.ok === false) {
      if (res.error === 'expired') {
        msg = 'Dieser Code ist leider abgelaufen.'
      } else if (res.error === 'added') {
        msg = 'Dieser Code wurde bereits zu Ihrer Bestellung hinzugefügt.'
      } else {
        msg = 'Dieser Code ist nicht gültig.'
      }
    } else if (!res.ok) {
      msg = 'Es ist ein unbekannter Fehler aufgetreten.'
    } else {
      const coupon = res.coupon

      this.info.internal.coupons.push(coupon)
      this.info.api.couponCodes.push(this.couponField.val())

      this.updateAddedCoupons()
      this.trackPiwikGoal(2)

      if (coupon.seats) {
        msg += ' Es wurden exklusive Sitzplätze für Sie freigeschaltet.'
      }
    }

    this.couponField.blur().val('')
    this.delegate.toggleModalSpinner(false)
    this.updateCouponResult(msg, !res.ok)
    this.resizeDelegateBox()

    this.addBreadcrumb('entered coupon code', {
      code: res.coupon,
      success: res.ok ? 'true' : 'false',
      error: res.error
    })
  }

  this.updateCouponResult = function (msg, error) {
    this.couponBox.find('.msg .result')
      .text(msg).toggleClass('error', error).parent().toggle(!!msg)
  }

  this.updateAddedCoupons = function () {
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

  this.updateDiscounts = function () {
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

  this.nextBtnEnabled = function () {
    return this.info.internal.numberOfTickets > 0
  }

  this.validate = function () {
    if (this.couponField.val() !== '') {
      this.addCoupon()
      return false
    }
    return true
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
  this.box.find('.event-header').load(() => this.resizeDelegateBox(true))
}

function SeatsStep (delegate) {
  this.chooser = null

  this.validate = function () {
    return !this.hasSeatingPlan || this.chooser.validate()
  }

  this.nextBtnEnabled = function () {
    return !!this.info.api.date
  }

  this.willMoveIn = function () {
    if (!this.hasSeatingPlan) return

    const info = this.delegate.getStepInfo('tickets')
    if (this.numberOfSeats !== info.internal.numberOfTickets) {
      this.numberOfSeats = info.internal.numberOfTickets
      togglePluralText(
        this.box.find('.note.number_of_tickets'), this.numberOfSeats
      )
      this.chooser.toggleErrorBox(false)
      this.updateSeatingPlan()
    }
    this.toggleExclusiveSeatsKey(info.internal.exclusiveSeats)
  }

  this.didMoveIn = function () {
    if (this.skipDateSelection) {
      this.choseDate(this.dates.first())
    }
  }

  this.choseDate = function ($this) {
    if ($this.is('.selected') || $this.is('.disabled')) return
    $this.parents('table').find('.selected').removeClass('selected')
    $this.addClass('selected')

    this.info.api.date = $this.data('id')
    this.info.internal.boxOfficePayment = $this.data('box-office-payment')
    this.info.internal.localizedDate = $this.text()

    if (this.hasSeatingPlan) {
      this.slideToggle(this.seatingBox, true)
      this.updateSeatingPlan()

      $('html, body').animate({ scrollTop: this.seatingBox.offset().top }, 500)
    } else {
      this.delegate.updateNextBtn()
    }

    this.addBreadcrumb('set date', {
      date: this.info.api.date
    })
  }

  this.updateSeatingPlan = function () {
    this.delegate.toggleModalSpinner(true)
    this.chooser.setDateAndNumberOfSeats(
      this.info.api.date, this.numberOfSeats, () => {
        this.delegate.toggleModalSpinner(false)
      }
    )
  }

  this.enableReservationGroups = function () {
    const groups = []
    for (const element of this.box.find('.reservationGroups :checkbox')) {
      const $this = $(element)
      if ($this.is(':checked')) groups.push($this.prop('name'))
    }

    this.delegate.toggleModalSpinner(true)
    $.post(this.box.find('.reservationGroups').data('enable-url'), {
      groups: groups,
      socketId: this.delegate.getStepInfo('seats').api.socketId
    }).always(res => {
      this.delegate.toggleModalSpinner(false)
      this.toggleExclusiveSeatsKey(res.seats)
      this.resizeDelegateBox()
    })
  }

  this.toggleExclusiveSeatsKey = function (toggle) {
    this.chooser.toggleExclusiveSeatsKey(toggle)
  }

  this.expire = function () {
    this.delegate.expire()
    this.addBreadcrumb('session expired')
  }

  this.seatChooserIsReady = function () {
    this.info.api.socketId = this.chooser.socketId
    this.delegate.toggleModalSpinner(false)
  }

  this.seatChooserIsReconnecting = function () {
    this.delegate.toggleModalSpinner(true, true)
  }

  this.seatChooserDisconnected = function () {
    this.delegate.showModalAlert('Die Verbindung zum Server wurde unterbrochen.<br />Bitte geben Sie Ihre Bestellung erneut auf.<br />Wir entschuldigen uns für diesen Vorfall.')
  }

  this.seatChooserCouldNotConnect = function () {
    this.delegate.showModalAlert('Derzeit ist keine Buchung möglich.<br />Bitte versuchen Sie es zu einem späteren Zeitpunkt erneut.')
  }

  this.seatChooserCouldNotReconnect = function () {
    this.expire()
  }

  this.seatChooserExpired = function () {
    this.expire()
  }

  Step.call(this, 'seats', delegate)

  this.hasSeatingPlan = this.box.data('hasSeatingPlan')
  this.seatingBox = this.box.find('.seat_chooser')
  if (this.hasSeatingPlan) {
    this.delegate.toggleModalSpinner(true, true)
    this.box.show()
    this.chooser = new SeatChooser(this.seatingBox.find('.seating'), this)
    this.chooser.init()
    this.box.hide()
  }
  this.seatingBox.hide()

  this.dates = this.box.find('.date td').click(event => {
    this.choseDate($(event.currentTarget))
  })
  this.skipDateSelection = this.dates.length < 2 && this.hasSeatingPlan
  this.box.find('.note').first().toggle(!this.skipDateSelection)

  this.box.find('.reservationGroups :checkbox')
    .prop('checked', false).click(() => this.enableReservationGroups())
}

function AddressStep (delegate) {
  this.validate = function () {
    return this.validateFields(() => {
      if (this.delegate.web) {
        for (const key of ['first_name', 'last_name', 'phone']) {
          this.validateField(key, 'Bitte füllen Sie dieses Feld aus.', field => {
            return this.valueNotEmpty(field.val())
          })
        }

        this.validateField('gender', 'Bitte wählen Sie eine Anrede aus.', field => {
          return field.val() >= 0
        })

        this.validateField('email_confirmation', 'Die e-mail-Adressen stimmen nicht überein.', field => {
          if (!this.valueNotEmpty(field.val())) return false
          return field.val() === this.getFieldWithKey('email').val()
        })
      }

      this.validateField('email', 'Bitte geben Sie eine korrekte e-mail-Adresse an.', field => {
        if (!this.delegate.web && !this.valueNotEmpty(field.val())) return true
        return this.fieldIsEmail(field)
      })

      this.validateField('plz', 'Bitte geben Sie eine korrekte Postleitzahl an.', field => {
        if (!this.delegate.web && !this.valueNotEmpty(field.val())) return true
        return this.valueOnlyDigits(field.val()) && field.val().length === 5
      })
    })
  }

  Step.call(this, 'address', delegate)
}

function PaymentStep (delegate) {
  this.willMoveIn = function () {
    if (this.delegate.web) {
      const boxOffice = this.delegate.getStepInfo('seats').internal.boxOfficePayment
      this.box.find('.transfer').toggle(!boxOffice)
      this.box.find('.box_office').toggle(boxOffice)

      if (!boxOffice && this.info.api.method === 'box_office') {
        this.info.api.method = null
      }
    }
  }

  this.validate = function () {
    if (this.methodIsCharge()) {
      return this.validateFields(() => {
        this.validateField('name', 'Bitte geben Sie den Kontoinhaber an.', field => {
          return this.valueNotEmpty(field.val())
        })
        this.validateField('iban', 'Die angegebene IBAN ist nicht korrekt. Bitte überprüfen Sie sie noch einmal.', field => {
          return this.valueIsIBAN(field.val())
        })
      })
    }

    return true
  }

  this.methodIsCharge = function () {
    return this.info.api.method === 'charge'
  }

  this.nextBtnEnabled = function () {
    return !!this.info.api.method
  }

  this.shouldBeSkipped = function () {
    return this.delegate.getStepInfo('tickets').internal.zeroTotal
  }

  Step.call(this, 'payment', delegate)

  this.updateMethods = function () {
    if (this.methodIsCharge()) {
      setTimeout(() => this.getFieldWithKey('name').focus(), 750)
    }
  }

  this.registerEventAndInitiate(this.box.find('[name=method]'), 'click', $this => {
    if (!$this.is(':checked')) return
    this.info.api.method = $this.val()
    this.slideToggle(this.box.find('.charge_data'), this.methodIsCharge())
    this.delegate.updateNextBtn()
  })
}

function ConfirmStep (delegate) {
  Step.call(this, 'confirm', delegate)

  this.updateSummary = function (info, part) {
    for (const [key, value] of Object.entries(info)) {
      this.box.find(`.${part} .${key}`).text(value)
    }
  }

  this.willMoveIn = function () {
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

    for (const element of this.box.find('.tickets tbody tr').show()) {
      const typeBox = $(element)
      let number, total
      if (typeBox.is('.subtotal')) {
        number = ticketsInfo.internal.numberOfTickets
        total = this.formatCurrency(ticketsInfo.internal.subtotal)
      } else if (typeBox.is('.discount')) {
        if (ticketsInfo.internal.discount === 0) {
          typeBox.hide()
          continue
        }
        total = this.formatCurrency(ticketsInfo.internal.discount)
      } else if (typeBox.is('.total')) {
        total = this.formatCurrency(ticketsInfo.internal.total)
      } else {
        const typeId = typeBox.find('td').first().data('id')
        number = ticketsInfo.api.tickets[typeId]
        if (!number || number < 1) {
          typeBox.hide()
          continue
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
    }

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

  this.validate = function () {
    return this.validateFields(() => {}, () => {
      this.info.api.newsletter = this.info.api.newsletter === '1'
    })
  }

  this.validateAsync = function (callback) {
    this.delegate.toggleModalSpinner(true)
    this.placeOrder(callback)
  }

  this.placeOrder = function (successCallback) {
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

    $.ajax({
      url: '/api/ticketing/orders',
      type: 'POST',
      data: JSON.stringify(info),
      contentType: 'application/json',
      success: response => this.orderPlaced(response, successCallback),
      error: response => this.orderFailed()
    })
  }

  this.disconnect = function () {
    const chooser = this.delegate.getStep('seats').chooser
    if (chooser) chooser.disconnect()
    this.delegate.killExpirationTimer()
  }

  this.orderFailed = function () {
    this.disconnect()
    this.delegate.showModalAlert('Leider ist ein Fehler aufgetreten.<br />Ihre Bestellung konnte nicht aufgenommen werden.')
  }

  this.orderPlaced = function (response, callback) {
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

function FinishStep (delegate) {
  this.willMoveIn = function () {
    const payInfo = this.delegate.getStepInfo('payment')
    if (payInfo) {
      const immediateTickets =
        ['charge', 'credit_card'].indexOf(payInfo.api.method) > -1
      this.box.find('.tickets').toggle(immediateTickets)
    }

    const confirmInfo = this.delegate.getStepInfo('confirm')
    const orderInfo = confirmInfo.internal.order
    orderInfo.total = Number.parseFloat(orderInfo.total)

    if (this.delegate.retail) {
      const infoBox = this.box.find('.info')
      infoBox.find('.total span').text(this.formatCurrency(orderInfo.total))
      infoBox.find('.number').text(orderInfo.tickets.length)
      infoBox.find('a.details').prop('href', confirmInfo.internal.detailsPath)

      const printer = new TicketPrinter()
      setTimeout(() => {
        printer.printTicketsWithNotification(orderInfo.printable_path)
      }, 2000)

    } else {
      const email = this.delegate.getApiInfo().address.email
      const isGmail = /@(gmail|googlemail)\./.test(email)
      this.box.find('.gmail-warning').toggle(isGmail)

      this.box.find('.order-number b').text(orderInfo.number)
      this.trackPiwikGoal(1, orderInfo.total)
    }
  }

  Step.call(this, 'finish', delegate)
}

function Ordering () {
  this.currentStepIndex = -1
  this.steps = []
  this.expirationTimer = { type: 0, timer: null, times: [420, 60] }
  this.noFurtherErrors = false

  this.toggleBtn = function (btn, toggle, styleClass = 'disabled') {
    this.btns.filter(`.${btn}`).toggleClass(styleClass, !toggle)
  }

  this.toggleNextBtn = function (toggle, styleClass) {
    this.toggleBtn('next', toggle, styleClass)
  }

  this.setNextBtnText = function (text = 'weiter') {
    this.btns.filter('.next').find('.action').text(text)
  }

  this.updateNextBtn = function () {
    if (!this.currentStep) return
    this.toggleNextBtn(this.currentStep.nextBtnEnabled())
  }

  this.updateBtns = function () {
    this.toggleBtn('prev', this.currentStepIndex > 0)
    this.updateNextBtn()
  }

  this.hideOrderControls = function () {
    $('.progress, .btns').addClass('disabled')
  }

  this.goNext = function ($this) {
    if ($this.is('.disabled')) return

    if ($this.is('.prev')) {
      this.showPrev()
    } else {
      let scrollPos = this.stepBox
      if (this.currentStep.validate()) {
        this.currentStep.validateAsync(() => this.showNext(true))
      } else {
        const error = this.stepBox.find('.error:first-child')
        if (error.length) {
          scrollPos = error
        }
      }
      $('body').animate({ scrollTop: scrollPos.position().top })
    }
  }

  this.showNext = function (animate) {
    if (this.currentStep) {
      this.currentStep.moveOut(true)
    }
    this.updateCurrentStep(1)
    this.moveInCurrentStep(animate)
  }

  this.showPrev = function () {
    this.currentStep.moveOut(false)
    this.updateCurrentStep(-1)
    this.moveInCurrentStep()
  }

  this.toggleModalBox = function (toggle, stop, instant) {
    if (stop) this.modalBox.stop()
    if (instant) {
      this.modalBox.show()
      return this.modalBox
    }
    return this.modalBox['fade' + (toggle ? 'In' : 'Out')]()
  }

  this.toggleModalSpinner = function (toggle, instant) {
    if (toggle) {
      this.toggleNextBtn(false)
      this.toggleBtn('prev', false)
    } else {
      this.updateBtns()
    }
    this.toggleModalBox(toggle, true, instant)
  }

  this.showModalAlert = function (msg) {
    if (this.noFurtherErrors) return
    this.noFurtherErrors = true
    this.modalBox.find('.spinner').hide()
    this.killExpirationTimer()
    this.toggleModalBox(true).find('.messages').show()
      .find('li').first().html(msg)
    this.hideOrderControls()
  }

  this.updateCurrentStep = function (inc) {
    do {
      this.currentStepIndex += inc
      this.currentStep = this.steps[this.currentStepIndex]
    } while (this.currentStep.shouldBeSkipped())
  }

  this.updateProgress = function () {
    if (this.currentStepIndex === this.steps.length - 1) return

    this.progressBox.find('.current').removeClass('current')
    this.progressBox.find('.step.' + this.currentStep.name).addClass('current')
    const bar = this.progressBox.find('.bar')
    bar.css('left', bar.width() * this.currentStepIndex)
  }

  this.moveInCurrentStep = function (animate) {
    this.currentStep.moveIn(animate)
    this.updateBtns()
    this.updateProgress()
  }

  this.resizeStepBox = function (height, animated) {
    const props = { height: height }
    if (animated) {
      this.stepBox.animate(props)
    } else {
      this.stepBox.css(props)
    }
  }

  this.getStep = function (stepName) {
    return this.steps.find(step => step.name === stepName)
  }

  this.getStepInfo = function (stepName) {
    const step = this.getStep(stepName)
    if (step) return step.info
  }

  this.getApiInfo = function () {
    const info = {}
    for (const step of this.steps) {
      info[step.name] = step.info.api
    }
    return info
  }

  this.updateExpirationCounter = function (seconds) {
    if (this.expirationTimer.type === 0 && seconds < 1) {
      this.expirationTimer.type = 1
      seconds = this.expirationTimer.times[1]
      this.expirationBox.slideDown()
    }
    if (this.expirationTimer.type === 1) {
      if (seconds < 1) {
        this.expire()
        return
      }
      togglePluralText(this.expirationBox.find('li'), seconds)
    }
    this.expirationTimer.timer = setTimeout(() => {
      this.updateExpirationCounter(--seconds)
    }, 1000)
  }

  this.killExpirationTimer = function () {
    clearTimeout(this.expirationTimer.timer)
    this.expirationBox.slideUp()
  }

  this.resetExpirationTimer = function () {
    this.killExpirationTimer()
    if (this.noFurtherErrors) return
    this.expirationTimer.type = 0
    this.updateExpirationCounter(
      this.expirationTimer.times[0] - this.expirationTimer.times[1]
    )
  }

  this.expire = function () {
    this.showModalAlert('Ihre Sitzung ist abgelaufen.<br />Wenn Sie möchten, können Sie den Bestellvorgang erneut starten.')
  }

  this.registerEvents = function () {
    this.btns.click(event => this.goNext($(event.currentTarget)))

    $(document)
      .click(() => this.resetExpirationTimer())
      .keydown(() => this.resetExpirationTimer())

    const nextBtn = this.btns.filter('.next')
    $('.stepBox input:not(.noKeyCatch)').keyup(event => {
      if (event.which === 13) this.goNext(nextBtn)
    })
  }

  this.stepBox = $('.stepBox')
  if (!this.stepBox) return
  this.expirationBox = $('.expiration')
  this.btns = $('.btns .btn')
  this.progressBox = $('.progress')
  this.modalBox = this.stepBox.find('.modalAlert')

  this.type = this.stepBox.data('type')
  this.retail = this.type === 'retail'
  this.admin = this.type === 'admin'
  this.web = !this.retail && !this.admin

  let steps
  if (this.retail) {
    steps = [TicketsStep, SeatsStep, ConfirmStep, FinishStep]
  } else {
    steps = [TicketsStep, SeatsStep, AddressStep, PaymentStep, ConfirmStep,
      FinishStep]
  }

  const progressSteps = this.progressBox.find('.step')
  const width = this.progressBox.width() / (steps.length - 1)
  progressSteps.css({ width: width }).filter('.bar').css({ width: Math.round(width) })

  for (const stepClass of steps) {
    stepClass.prototype = Step.prototype
    const step = new (eval(stepClass))(this)
    this.steps.push(step)

    progressSteps.filter(`.${step.name}`).show()
  }

  this.registerEvents()
  this.showNext(false)
  this.resetExpirationTimer()
}

$(() => {
  if ($('.stepBox').length) new Ordering()
})
