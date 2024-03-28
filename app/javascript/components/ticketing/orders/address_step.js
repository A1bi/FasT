import Step from 'components/ticketing/orders/step'

export default class extends Step {
  constructor (delegate) {
    super('address', delegate)
  }

  validate () {
    return this.validateFields(() => {
      if (this.delegate.web) {
        for (const key of ['first_name', 'last_name', 'phone']) {
          this.validateField(key, 'Bitte füllen Sie dieses Feld aus.', field => {
            return this.valueNotEmpty(field.value)
          })
        }

        this.validateField('gender', 'Bitte wählen Sie eine Anrede aus.', field => {
          return parseInt(field.value) >= 0
        })
      }

      this.validateField('email', 'Bitte geben Sie eine korrekte E-Mail-Adresse an.', field => {
        if (!this.delegate.web && !this.valueNotEmpty(field.value)) return true
        return this.fieldIsEmail(field)
      })

      this.validateField('plz', 'Bitte geben Sie eine korrekte Postleitzahl an.', field => {
        if (!this.delegate.web && !this.valueNotEmpty(field.value)) return true
        return this.valueOnlyDigits(field.value) && field.value.length === 5
      })
    })
  }
}
