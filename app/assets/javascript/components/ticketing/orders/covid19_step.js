import Step from './step'

export default class extends Step {
  constructor (delegate) {
    super('covid19', delegate)
  }

  willMoveIn () {
    this.updateForms()
    this.fillInitialAddress()
  }

  validate () {
    const valid = this.visibleForms.toArray().every(form => {
      if (form.reportValidity) {
        return form.reportValidity()
      } else {
        return form.checkValidity()
      }
    })

    if (valid) {
      this.info.api.attendees = []
      this.visibleForms.toArray().forEach(form => {
        const attendee = {}
        this.info.api.attendees.push(attendee)

        form.querySelectorAll("input:not([type='checkbox']").forEach(field => {
          attendee[field.name] = field.value
        })
      })
    } else if (!this.forms[0].reportValidity) {
      window.alert('Bitte füllen Sie alle Felder aus.')
    }

    return valid
  }

  fillInitialAddress () {
    if (this.initialized) return

    this.initialized = true

    const name = `${this.initialAddress.first_name} ${this.initialAddress.last_name}`
    this.setFirstFormValue('name', name)
    const fieldNames = ['plz', 'phone']
    fieldNames.forEach(fieldName => {
      this.setFirstFormValue(fieldName, this.initialAddress[fieldName])
    })
  }

  setFirstFormValue (fieldName, value) {
    const firstForm = this.visibleForms[0]
    firstForm.querySelector(`input[name='${fieldName}']`).value = value
  }

  updateForms () {
    const numberOfForms = this.visibleForms.length

    for (let i = numberOfForms; i < this.numberOfTickets; i++) {
      const form = this.formTemplate.clone().insertAfter(this.forms.last())
      form.show().removeAttr('data-template')

      const title = form.find('th')
      title.text(title.text().replace('%number%', i + 1))

      if (i === 0) {
        form.find('.same-address').remove()

        form.find('input').on('input', (event) => {
          if (event.currentTarget.name === 'name') return

          this.updateFields()
        })
      } else {
        form.find(':checkbox').on('change', (event) => {
          const checked = event.currentTarget.checked
          const fields = form.find(":not(:checkbox):not([name='name'])")
          fields.attr('disabled', checked)
          this.updateFields()
        })
      }
    }

    for (let i = numberOfForms; i > this.numberOfTickets; i--) {
      this.visibleForms[i - 1].remove()
    }
  }

  updateFields () {
    this.visibleForms.toArray().forEach(form => {
      const checkbox = form.querySelector("input[type='checkbox']")
      if (!checkbox || !checkbox.checked) return

      this.visibleForms[0].querySelectorAll('input').forEach(source => {
        if (source.name === 'name') return

        const target = form.querySelector(`input[name='${source.name}']`)
        target.value = source.value
      })
    })
  }

  get formTemplate () {
    return this.forms.filter('[data-template]').hide()
  }

  get visibleForms () {
    return this.forms.filter(':not([data-template])')
  }

  get forms () {
    return this.box.find('form')
  }

  get numberOfTickets () {
    return this.delegate.getStepInfo('tickets').internal.numberOfTickets
  }

  get initialAddress () {
    return this.delegate.getStepInfo('address').api
  }
}
