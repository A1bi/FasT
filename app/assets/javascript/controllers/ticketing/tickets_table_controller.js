import { Controller } from 'stimulus'
import { getAuthenticityToken } from '../../components/utils'

export default class extends Controller {
  static targets = ['action', 'reason']

  initialize () {
    this.element.querySelector("[name='authenticity_token']").value =
      getAuthenticityToken()
    this.toggleReason()
  }

  toggleReason () {
    this.reasonTarget.style.display =
      this.actionTarget.value === 'cancel' ? 'inline' : 'none'
  }

  submit (event) {
    const current = this.actionTarget.selectedOptions[0]
    const method = current.dataset.method
    if (current.dataset.confirm && !window.confirm(current.dataset.confirm)) {
      return event.preventDefault()
    }

    this.element.setAttribute('action', current.dataset.path)
    this.element.setAttribute('method', method === 'get' ? method : 'post')
    this.element.querySelector("[name='_method']").value = method
  }
}
