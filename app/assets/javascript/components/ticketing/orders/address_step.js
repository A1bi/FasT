import Step from './step'

export default class extends Step {
  constructor (delegate) {
    super('address', delegate)
  }

  validate () {
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
}
