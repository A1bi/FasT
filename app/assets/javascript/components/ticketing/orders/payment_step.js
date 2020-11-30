import Step from './step'

export default class extends Step {
  constructor (delegate) {
    super('payment', delegate)

    this.registerEventAndInitiate(this.box.find('[name=method]'), 'click', $this => {
      if (!$this.is(':checked')) return

      this.info.api.method = $this.val()
      this.slideToggle(this.box.find('.charge_data'), this.methodIsCharge())
      this.delegate.updateNextBtn()
    })
  }

  willMoveIn () {
    if (this.delegate.web) {
      const boxOffice = this.delegate.getStepInfo('seats')?.internal.boxOfficePayment
      this.box.find('.transfer').toggle(!boxOffice)
      this.box.find('.box_office').toggle(boxOffice)

      if (!boxOffice && this.info.api.method === 'box_office') {
        this.info.api.method = null
      }
    }
  }

  validate () {
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
