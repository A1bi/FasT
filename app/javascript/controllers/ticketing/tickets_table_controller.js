import { Controller } from '@hotwired/stimulus'
import { getAuthenticityToken, toggleDisplay } from 'components/utils'

export default class extends Controller {
  static targets = ['ticketCheckBox', 'noTicketsMessage', 'form', 'action', 'cancellation',
    'refundDetails', 'bankDetails', 'submitButton', 'bankDetailsCheckbox']

  initialize () {
    this.element.querySelector("[name='authenticity_token']").value =
      getAuthenticityToken()
    this.toggleForm()
    this.toggleCancellationForm()
  }

  toggleAllCheckBoxes (event) {
    this.ticketCheckBoxTargets.forEach(box => {
      box.checked = event.currentTarget.checked
    })
    this.toggleForm()
  }

  toggleForm () {
    if (!this.hasNoTicketsMessageTarget) return

    const anyChecked = this.ticketCheckBoxTargets.some(box => box.checked)
    toggleDisplay(this.noTicketsMessageTarget, !anyChecked)
    toggleDisplay(this.formTarget, anyChecked)
    this.toggleBankDetails()
  }

  toggleCancellationForm () {
    if (!this.hasCancellationTarget) return

    const label = this.actionTarget.selectedOptions[0].dataset.submitLabel ||
      this.submitButtonTarget.dataset.defaultLabel
    this.submitButtonTarget.value = label
    this.cancellationTargets.forEach(t => toggleDisplay(t, this.actionTarget.value === 'cancel'))
  }

  toggleRefundDetails (checkbox) {
    this.toggleBankDetails()
    this.refundDetailsTargets.forEach(target => {
      toggleDisplay(target, checkbox.currentTarget.checked)
    })
  }

  toggleBankDetails (checkbox) {
    const toggle =
      this.hasBankDetailsCheckboxTarget ? !this.bankDetailsCheckboxTarget.checked : true

    this.bankDetailsTargets.forEach(target => {
      toggleDisplay(target, toggle)
    })
  }

  submit (event) {
    const current = this.actionTarget.selectedOptions[0]
    const form = this.element.querySelector('form')
    const method = current.dataset.method
    if (current.dataset.confirm && !window.confirm(current.dataset.confirm)) {
      return event.preventDefault()
    }

    if (current.dataset.resale) {
      form.querySelectorAll(":scope [name='ticket_ids[]']").forEach(el => {
        const id = el.value
        const field = document.createElement('input')
        field.setAttribute('type', 'hidden')
        field.setAttribute('name', `ticketing_tickets[${id}][resale]`)
        field.setAttribute('value', true)
        form.append(field)
      })
    }

    form.setAttribute('action', current.dataset.path)
    form.setAttribute('method', method === 'get' ? method : 'post')
    form.querySelector("[name='_method']").value = method
  }
}
