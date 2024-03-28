import Step from 'components/ticketing/orders/step'
import { toggleDisplay } from 'components/utils'

export default class extends Step {
  constructor (delegate) {
    super('payment', delegate)

    this.box.querySelectorAll(':scope [name=method]').forEach(radio => {
      radio.addEventListener('change', () => {
        if (!radio.checked) return
        this.info.api.method = radio.value
        this.slideToggle(this.box.querySelector('.charge_data'), this.methodIsCharge())
        this.delegate.updateNextBtn()
      })
    })
  }

  willMoveIn () {
    if (this.delegate.web) {
      const boxOffice = this.delegate.getStepInfo('seats')?.internal.boxOfficePayment
      toggleDisplay(this.box.querySelector('.transfer'), !boxOffice)
      toggleDisplay(this.box.querySelector('.box_office'), boxOffice)

      if (!boxOffice && this.info.api.method === 'box_office') {
        this.info.api.method = null
      }
    }
  }

  validate () {
    if (this.methodIsCharge()) {
      return this.validateFields(() => {
        this.validateField('name', 'Bitte geben Sie den Kontoinhaber an.', field => {
          return this.valueNotEmpty(field.value)
        })
        this.validateField('iban', 'Die angegebene IBAN ist nicht korrekt. Bitte überprüfen Sie sie noch einmal.', field => {
          return this.valueIsIBAN(field.value)
        })
      })
    }

    return true
  }

  methodIsCharge () {
    return this.info.api.method === 'charge'
  }

  nextBtnEnabled () {
    return !!this.info.api.method
  }

  shouldBeSkipped () {
    return this.delegate.getStepInfo('tickets')?.internal.zeroTotal
  }
}
