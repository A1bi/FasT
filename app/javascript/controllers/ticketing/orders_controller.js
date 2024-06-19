import { Controller } from '@hotwired/stimulus'
import TicketsStep from 'components/ticketing/orders/tickets_step'
import CouponsStep from 'components/ticketing/orders/coupons_step'
import SeatsStep from 'components/ticketing/orders/seats_step'
import AddressStep from 'components/ticketing/orders/address_step'
import PaymentStep from 'components/ticketing/orders/payment_step'
import ConfirmationStep from 'components/ticketing/orders/confirmation_step'
import FinishStep from 'components/ticketing/orders/finish_step'
import { toggleDisplay, toggleDisplayIfExists, togglePluralText, fetch } from 'components/utils'

export default class extends Controller {
  static values = {
    stripeKey: String
  }

  static stripePaymentMethods = {
    applePay: 'apple_pay',
    googlePay: 'google_pay'
  }

  async initialize () {
    this.currentStepIndex = -1
    this.steps = []
    this.expirationTimer = { type: 0, timer: null, times: [420, 60] }
    this.noFurtherErrors = false
    this.modalBoxOwners = 0

    this.stepBox = this.element
    this.orderFrameBox = document.querySelector('.order-framework')
    this.expirationBox = document.querySelector('.expiration')
    this.btns = document.querySelectorAll('.btns .btn')
    this.progressBox = document.querySelector('.progress')
    this.modalBox = this.stepBox.querySelector('.modalAlert')

    this.eventId = this.element.dataset.eventId
    this.coupons = this.element.dataset.coupons
    this.type = this.element.dataset.type
    this.retail = this.type === 'retail'
    this.admin = this.type === 'admin'
    this.web = !this.retail && !this.admin

    this.orderTotal = 0
    this.orderDiscount = 0
    this.clearLineItems()

    let steps
    if (this.coupons) {
      steps = { CouponsStep, AddressStep, PaymentStep, ConfirmationStep, FinishStep }
    } else if (this.retail) {
      steps = { TicketsStep, SeatsStep, ConfirmationStep, FinishStep }
    } else {
      steps = {
        TicketsStep, SeatsStep, AddressStep, PaymentStep, ConfirmationStep, FinishStep
      }
    }

    for (const stepClass in steps) {
      const step = new steps[stepClass](this)
      this.steps.push(step)

      const stepBox = this.progressBox.querySelector(`:scope .step.${step.name}`)
      toggleDisplayIfExists(stepBox, true)
    }

    this.registerEvents()
    this.resetExpirationTimer()

    this.toggleModalBox(true)

    await this.initStripePaymentRequest()

    // await layouting of all steps so initial stepBox height is correct
    setTimeout(() => {
      this.showNext()
      this.toggleModalBox(false)
    }, 250)
  }

  toggleBtn (btn, toggle) {
    this.getBtn(btn).disabled = !toggle
  }

  toggleNextBtn (toggle) {
    this.toggleBtn('next', toggle)
  }

  setNextBtnText (text = 'weiter') {
    this.getBtn('next').textContent = text
  }

  getBtn (btn) {
    return [...this.btns].find(b => b.matches(`.${btn}`))
  }

  updateBtns () {
    if (!this.currentStep) return

    this.toggleBtn('prev', this.currentStepIndex > 0)
    this.toggleNextBtn(this.currentStep.nextBtnEnabled())

    const showApplePayButton = this.currentStep.finalizesOrder && this.stripePaymentSelected &&
      this.availableStripePaymentMethod === 'apple_pay'
    toggleDisplay(this.getBtn('apple_pay'), showApplePayButton)
    toggleDisplay(this.getBtn('next'), !showApplePayButton)
  }

  goPrev () {
    this.showPrev()
  }

  goNext () {
    if (!this.currentStep.validate()) return

    if (this.currentStep.finalizesOrder) {
      if (this.stripePaymentSelected) {
        this.showStripePaymentSheet()
      } else {
        this.placeOrder()
      }
    } else {
      this.showNext()
      this.orderFrameBox.scrollIntoView({ behavior: 'smooth' })
    }
  }

  showNext () {
    const previousStep = this.currentStep
    if (this.currentStep) this.currentStep.moveOut(true)
    this.updateCurrentStep(1)
    this.moveInCurrentStep(previousStep)
  }

  showPrev () {
    const previousStep = this.currentStep
    this.currentStep.moveOut(false)
    this.updateCurrentStep(-1)
    this.moveInCurrentStep(previousStep)
  }

  toggleModalBox (toggle, spinner = true, orderControls = true) {
    document.querySelectorAll('.progress, .btns').forEach(el => {
      el.style.visibility = orderControls ? 'visible' : 'hidden'
    })

    if (orderControls) {
      if (toggle) {
        this.toggleNextBtn(false)
        this.toggleBtn('prev', false)
      } else {
        this.updateBtns()
      }
    }

    toggleDisplay(this.modalBox.querySelector('.spinner'), spinner)

    this.modalBoxOwners = Math.max(0, this.modalBoxOwners + (toggle ? 1 : -1))
    this.modalBox.classList.toggle('visible', this.modalBoxOwners > 0)
  }

  showModalAlert (msg) {
    if (this.noFurtherErrors) return
    this.noFurtherErrors = true
    this.killExpirationTimer()
    this.toggleModalBox(true, false, false)

    const alert = this.modalBox.querySelector('.alert')
    alert.querySelector('.message').innerHTML = msg
    toggleDisplay(alert, true)
  }

  slideToggle (target, toggle) {
    if (toggle) {
      target.style.maxHeight = `${target.scrollHeight}px`
      target.addEventListener('transitionend', event => {
        if (event.propertyName !== 'max-height' || !event.target.style.maxHeight) return
        target.classList.add('visible')
      }, { once: true })
    } else {
      target.classList.remove('visible')
      setTimeout(() => { target.style.maxHeight = null }, 0)
    }
  }

  updateCurrentStep (inc) {
    do {
      this.currentStepIndex += inc
      this.currentStep = this.steps[this.currentStepIndex]
    } while (this.currentStep.shouldBeSkipped())
  }

  updateProgress () {
    if (this.currentStepIndex === this.steps.length - 1) return

    this.progressBox.querySelector('.current').classList.remove('current')
    this.progressBox.querySelector(`.step.${this.currentStep.name}`).classList.add('current')
  }

  moveInCurrentStep (previousStep) {
    this.orderFrameBox.classList.toggle('w-100', this.currentStep.needsFullWidth())
    this.currentStep.moveIn()
    this.updateBtns()
    this.updateProgress()
    this.setStepBoxHeight(previousStep)
  }

  setStepBoxHeight (previousStep) {
    const minHeight = parseInt(window.getComputedStyle(this.stepBox).minHeight)
    const stepHeight = (previousStep || this.currentStep).box.offsetHeight
    const height = Math.max(minHeight, stepHeight)
    this.stepBox.classList.add('initialized')
    this.stepBox.style.height = `${height}px`

    if (previousStep) setTimeout(() => this.setStepBoxHeight(), 0)
  }

  removeStepBoxHeight () {
    this.stepBox.style.height = null
  }

  getStep (stepName) {
    return this.steps.find(step => step.name === stepName)
  }

  getStepInfo (stepName) {
    const step = this.getStep(stepName)
    if (step) return step.info
  }

  getApiInfo () {
    const info = {}
    for (const step of this.steps) {
      info[step.name] = step.info.api
    }
    return info
  }

  addLineItem (label, price, number) {
    const item = {
      label,
      price,
      number,
      total: price * number
    }
    if (number > 0) this.lineItems.push(item)
    return item
  }

  clearLineItems () {
    this.lineItems = []
  }

  get numberOfArticles () {
    return this.lineItems.reduce((acc, item) => acc + item.number, 0)
  }

  get paymentRequired () {
    return this.orderTotal > 0
  }

  async placeOrder () {
    this.toggleModalBox(true)

    try {
      const response = await fetch('/api/ticketing/orders', 'post', this.orderPayload)

      this.toggleModalBox(false, false, false)

      this.placedOrder = response

      if (this.stepBox.dataset.orderPath) {
        this.orderDetailsPath = this.stepBox.dataset.orderPath.replace(':id', this.placedOrder.id)

        if (this.admin) {
          window.location = this.orderDetailsPath
          return
        }
      }

      this.showNext()
    } catch (error) {
      console.log(error)
      this.showModalAlert('Leider ist ein Fehler aufgetreten.<br />Ihre Bestellung konnte nicht aufgenommen werden.')
    } finally {
      const chooser = this.getStep('seats')?.chooser
      if (chooser) chooser.disconnect()
      this.killExpirationTimer()
    }
  }

  get orderPayload () {
    const apiInfo = this.getApiInfo()
    return {
      order: {
        date: apiInfo.seats?.date,
        tickets: apiInfo.tickets?.tickets,
        coupons: apiInfo.coupons?.coupons,
        address: apiInfo.address,
        payment: apiInfo.payment,
        coupon_codes: apiInfo.tickets?.couponCodes
      },
      type: this.type,
      socket_id: apiInfo.seats?.socketId,
      newsletter: apiInfo.confirm.newsletter
    }
  }

  async initStripe () {
    if (this.stripe) return

    const { loadStripe } = await import('@stripe/stripe-js')
    this.stripe = await loadStripe(this.stripeKeyValue)
  }

  async initStripePaymentRequest () {
    if (!this.web || !this.stripePaymentAvailable) return

    await this.initStripe()

    this.stripePaymentRequest = this.stripe.paymentRequest({
      country: 'DE',
      currency: 'eur',
      total: {
        label: 'Total',
        amount: 1
      },
      requestPayerName: true
    })

    const stripePaymentAvailability = await this.stripePaymentRequest.canMakePayment()
    const availableMethod = Object.entries(stripePaymentAvailability || {}).find(([method, available]) => available)
    if (!availableMethod) return

    this.availableStripePaymentMethod = this.constructor.stripePaymentMethods[availableMethod[0]]

    this.stripePaymentRequest.on('paymentmethod', async event => {
      event.complete('success')

      this.toggleModalBox(false)
      this.placeOrder()
    })

    this.stripePaymentRequest.on('cancel', event => {
      this.toggleModalBox(false)
    })
  }

  async updateStripePaymentRequest () {
    this.stripePaymentRequest.update({
      country: 'DE',
      currency: 'eur',
      displayItems: this.stripePaymentDisplayItems,
      total: {
        label: 'Gesamt',
        amount: this.orderTotal * 100
      }
    })
  }

  showStripePaymentSheet () {
    this.toggleModalBox(true, false)
    this.updateStripePaymentRequest()
    this.stripePaymentRequest.show()
  }

  get stripePaymentDisplayItems () {
    const displayItems = this.lineItems.map(lineItem => {
      return Array(lineItem.number).fill({
        label: lineItem.label,
        amount: lineItem.price * 100
      })
    }).flat()

    if (this.orderDiscount !== 0) {
      displayItems.push({
        label: 'Abzug durch Gutscheine',
        amount: this.orderDiscount * 100
      })
    }

    return displayItems
  }

  get stripePaymentSelected () {
    const payment = this.getStepInfo('payment')
    return payment?.api?.method === 'stripe'
  }

  get stripePaymentAvailable () {
    return !window.ApplePaySession || window.ApplePaySession.canMakePayments
  }

  updateExpirationCounter (seconds) {
    if (this.expirationTimer.type === 0 && seconds < 1) {
      this.expirationTimer.type = 1
      seconds = this.expirationTimer.times[1]
      this.slideToggle(this.expirationBox, true)
    }
    if (this.expirationTimer.type === 1) {
      if (seconds < 1) {
        this.expire()
        return
      }
      togglePluralText(this.expirationBox, seconds)
    }
    this.expirationTimer.timer = setTimeout(() => {
      this.updateExpirationCounter(--seconds)
    }, 1000)
  }

  killExpirationTimer () {
    if (!this.expirationBox) return
    clearTimeout(this.expirationTimer.timer)
    this.slideToggle(this.expirationBox, false)
  }

  resetExpirationTimer () {
    if (!this.expirationBox) return
    this.killExpirationTimer()
    if (this.noFurtherErrors) return
    this.expirationTimer.type = 0
    this.updateExpirationCounter(
      this.expirationTimer.times[0] - this.expirationTimer.times[1]
    )
  }

  expire () {
    this.showModalAlert('Ihre Sitzung ist abgelaufen.<br>Wenn Sie möchten, können Sie den Bestellvorgang erneut starten.')
  }

  registerEvents () {
    this.btns.forEach(btn => {
      btn.addEventListener('click', event => {
        if (event.currentTarget.matches('.prev')) {
          this.goPrev()
        } else {
          this.goNext()
        }
      })
    })

    this.stepBox.addEventListener('transitionend', event => {
      if (event.propertyName === 'height') this.removeStepBoxHeight()
    })

    const events = ['click', 'keydown']
    events.forEach(event => {
      document.addEventListener(event, () => this.resetExpirationTimer())
    })

    document.querySelectorAll('.stepBox input:not(.noKeyCatch)').forEach(input => {
      input.addEventListener('keyup', event => {
        if (event.code === 'Enter') this.goNext(this.getBtn('next'))
      })
    })
  }
}
