import { Controller } from '@hotwired/stimulus'
import TicketsStep from 'components/ticketing/orders/tickets_step'
import CouponsStep from 'components/ticketing/orders/coupons_step'
import SeatsStep from 'components/ticketing/orders/seats_step'
import AddressStep from 'components/ticketing/orders/address_step'
import PaymentStep from 'components/ticketing/orders/payment_step'
import ConfirmationStep from 'components/ticketing/orders/confirmation_step'
import FinishStep from 'components/ticketing/orders/finish_step'
import { toggleDisplay, togglePluralText } from 'components/utils'

export default class extends Controller {
  initialize () {
    this.currentStepIndex = -1
    this.steps = []
    this.expirationTimer = { type: 0, timer: null, times: [420, 60] }
    this.noFurtherErrors = false

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
      if (stepBox) toggleDisplay(stepBox, true)
    }

    this.registerEvents()
    this.showNext(false)
    this.resetExpirationTimer()
    this.updateBoxSizes()
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

  updateNextBtn () {
    if (!this.currentStep) return
    this.toggleNextBtn(this.currentStep.nextBtnEnabled())
  }

  updateBtns () {
    this.toggleBtn('prev', this.currentStepIndex > 0)
    this.updateNextBtn()
  }

  hideOrderControls () {
    document.querySelectorAll('.progress, .btns').forEach(el => { el.style.visibility = 'hidden' })
  }

  goNext (btn) {
    if (btn.matches('.prev')) {
      this.showPrev()
    } else {
      let scrollPos = document.querySelector('main')
      if (this.currentStep.validate()) {
        this.currentStep.validateAsync(() => this.showNext(true))
      } else {
        const error = this.stepBox.querySelector('.was-validated :invalid')
        if (error) scrollPos = error
      }
      scrollPos.scrollIntoView()
    }
  }

  showNext (animate) {
    if (this.currentStep) {
      this.currentStep.moveOut(true)
    }
    this.updateCurrentStep(1)
    this.moveInCurrentStep(animate)
  }

  showPrev () {
    this.currentStep.moveOut(false)
    this.updateCurrentStep(-1)
    this.moveInCurrentStep()
  }

  toggleModalBox (toggle) {
    this.modalBox.classList.toggle('visible', toggle)
  }

  toggleModalSpinner (toggle) {
    if (toggle) {
      this.toggleNextBtn(false)
      this.toggleBtn('prev', false)
    } else {
      this.updateBtns()
    }
    this.toggleModalBox(toggle)
  }

  showModalAlert (msg) {
    if (this.noFurtherErrors) return
    this.noFurtherErrors = true
    toggleDisplay(this.modalBox.querySelector('.spinner'), false)
    this.killExpirationTimer()
    this.toggleModalBox(true)

    const alert = this.modalBox.querySelector('.alert')
    alert.querySelector('.message').innerHTML = msg
    toggleDisplay(alert, true)
    this.hideOrderControls()
  }

  slideToggle (target, toggle) {
    const maxHeight = toggle ? target.scrollHeight : 0
    target.style.maxHeight = `${maxHeight}px`
    this.resizeStepBox()
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

  moveInCurrentStep (animate) {
    this.orderFrameBox.classList.toggle('w-100', this.currentStep.needsFullWidth())
    this.currentStep.moveIn(animate)
    this.updateBoxSizes()
    this.updateBtns()
    this.updateProgress()
  }

  resizeStepBox () {
    if (!this.currentStep) return
    this.stepBox.style.height = `${this.currentStep.box.offsetHeight}px`
  }

  updateBoxSizes () {
    this.resizeStepBox()
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
    this.orderFrameBox.addEventListener('transitionend', () => this.updateBoxSizes())

    this.btns.forEach(btn => btn.addEventListener('click', () => this.goNext(btn)))

    const events = ['click', 'keydown']
    events.forEach(event => {
      document.addEventListener(event, () => this.resetExpirationTimer())
    })

    document.querySelectorAll('.stepBox input:not(.noKeyCatch)').forEach(input => {
      input.addEventListener('keyup', event => {
        if (event.code === 'Enter') this.goNext(this.getBtn('next'))
      })
    })

    window.addEventListener('resize', () => this.updateBoxSizes())
  }
}
