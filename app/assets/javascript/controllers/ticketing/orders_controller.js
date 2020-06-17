import { Controller } from 'stimulus'
import TicketsStep from '../../components/ticketing/orders/tickets_step'
import SeatsStep from '../../components/ticketing/orders/seats_step'
import AddressStep from '../../components/ticketing/orders/address_step'
import Covid19Step from '../../components/ticketing/orders/covid19_step'
import PaymentStep from '../../components/ticketing/orders/payment_step'
import ConfirmationStep from '../../components/ticketing/orders/confirmation_step'
import FinishStep from '../../components/ticketing/orders/finish_step'
import { togglePluralText } from '../../components/utils'
import $ from 'jquery'

export default class extends Controller {
  initialize () {
    this.currentStepIndex = -1
    this.steps = []
    this.expirationTimer = { type: 0, timer: null, times: [420, 60] }
    this.noFurtherErrors = false

    this.stepBox = $(this.element)
    this.expirationBox = $('.expiration')
    this.btns = $('.btns .btn')
    this.progressBox = $('.progress')
    this.modalBox = this.stepBox.find('.modalAlert')

    this.type = this.element.dataset.type
    this.retail = this.type === 'retail'
    this.admin = this.type === 'admin'
    this.web = !this.retail && !this.admin

    let steps
    if (this.retail) {
      steps = { TicketsStep, SeatsStep, ConfirmationStep, FinishStep }
    } else if (this.element.dataset.covid19) {
      steps = {
        TicketsStep, SeatsStep, AddressStep, Covid19Step, PaymentStep, ConfirmationStep, FinishStep
      }
    } else {
      steps = {
        TicketsStep, SeatsStep, AddressStep, PaymentStep, ConfirmationStep, FinishStep
      }
    }

    const progressSteps = this.progressBox.find('.step')
    const width = this.progressBox.width() / (Object.keys(steps).length - 1)
    progressSteps.css({ width: width }).filter('.bar').css({ width: Math.round(width) })

    for (const stepClass in steps) {
      const step = new steps[stepClass](this)
      this.steps.push(step)

      progressSteps.filter(`.${step.name}`).show()
    }

    this.registerEvents()
    this.showNext(false)
    this.resetExpirationTimer()
  }

  toggleBtn (btn, toggle, styleClass = 'disabled') {
    this.btns.filter(`.${btn}`).toggleClass(styleClass, !toggle)
  }

  toggleNextBtn (toggle, styleClass) {
    this.toggleBtn('next', toggle, styleClass)
  }

  setNextBtnText (text = 'weiter') {
    this.btns.filter('.next').find('.action').text(text)
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
    $('.progress, .btns').addClass('disabled')
  }

  goNext ($this) {
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

  toggleModalBox (toggle, stop, instant) {
    if (stop) this.modalBox.stop()
    if (instant) {
      this.modalBox.show()
      return this.modalBox
    }
    return this.modalBox['fade' + (toggle ? 'In' : 'Out')]()
  }

  toggleModalSpinner (toggle, instant) {
    if (toggle) {
      this.toggleNextBtn(false)
      this.toggleBtn('prev', false)
    } else {
      this.updateBtns()
    }
    this.toggleModalBox(toggle, true, instant)
  }

  showModalAlert (msg) {
    if (this.noFurtherErrors) return
    this.noFurtherErrors = true
    this.modalBox.find('.spinner').hide()
    this.killExpirationTimer()
    this.toggleModalBox(true).find('.messages').show()
      .find('li').first().html(msg)
    this.hideOrderControls()
  }

  updateCurrentStep (inc) {
    do {
      this.currentStepIndex += inc
      this.currentStep = this.steps[this.currentStepIndex]
    } while (this.currentStep.shouldBeSkipped())
  }

  updateProgress () {
    if (this.currentStepIndex === this.steps.length - 1) return

    this.progressBox.find('.current').removeClass('current')
    this.progressBox.find('.step.' + this.currentStep.name).addClass('current')
    const bar = this.progressBox.find('.bar')
    bar.css('left', bar.width() * this.currentStepIndex)
  }

  moveInCurrentStep (animate) {
    this.currentStep.moveIn(animate)
    this.updateBtns()
    this.updateProgress()
  }

  resizeStepBox (height, animated) {
    const props = { height: height }
    if (animated) {
      this.stepBox.animate(props)
    } else {
      this.stepBox.css(props)
    }
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

  killExpirationTimer () {
    clearTimeout(this.expirationTimer.timer)
    this.expirationBox.slideUp()
  }

  resetExpirationTimer () {
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
    this.btns.click(event => this.goNext($(event.currentTarget)))

    $(document)
      .click(() => this.resetExpirationTimer())
      .keydown(() => this.resetExpirationTimer())

    const nextBtn = this.btns.filter('.next')
    $('.stepBox input:not(.noKeyCatch)').keyup(event => {
      if (event.which === 13) this.goNext(nextBtn)
    })
  }
}
