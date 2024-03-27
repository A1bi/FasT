import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['bankDetails']

  toggleBankDetails (event) {
    const visible = event.currentTarget.value === 'false'
    this.bankDetailsTarget.classList.toggle('d-none', !visible)

    const inputs = this.bankDetailsTarget.querySelectorAll(':scope input')
    inputs.forEach(input => (input.required = visible))
  }
}
