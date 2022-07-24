import { Controller } from 'stimulus'
import { getAuthenticityToken, toggleDisplay } from '../../components/utils'

export default class extends Controller {
  static targets = ['ticketCheckBox', 'noTicketsMessage', 'form', 'action', 'reason']

  initialize () {
    this.element.querySelector("[name='authenticity_token']").value =
      getAuthenticityToken()
    this.toggleForm()
    this.toggleReason()
  }

  toggleForm () {
    const anyChecked = this.ticketCheckBoxTargets.some(box => box.checked)
    toggleDisplay(this.noTicketsMessageTarget, !anyChecked)
    toggleDisplay(this.formTarget, anyChecked)
  }

  toggleReason () {
    toggleDisplay(this.reasonTarget, this.actionTarget.value === 'cancel', 'inline')
  }

  submit (event) {
    const current = this.actionTarget.selectedOptions[0]
    const method = current.dataset.method
    if (current.dataset.confirm && !window.confirm(current.dataset.confirm)) {
      return event.preventDefault()
    }

    if (current.dataset.resale) {
      this.element.querySelectorAll("[name='ticket_ids[]']").forEach(el => {
        const id = el.value
        const field = document.createElement('input')
        field.setAttribute('type', 'hidden')
        field.setAttribute('name', `ticketing_tickets[${id}][resale]`)
        field.setAttribute('value', true)
        this.element.append(field)
      })
    }

    this.element.setAttribute('action', current.dataset.path)
    this.element.setAttribute('method', method === 'get' ? method : 'post')
    this.element.querySelector("[name='_method']").value = method
  }
}
