import { Controller } from 'stimulus'

import '../../styles/ticketing/refund_controller.sass'

export default class extends Controller {
  static targets = ['bankDetails']

  toggleBankDetails (event) {
    const visible = event.currentTarget.value === 'false'
    this.bankDetailsTarget.classList.toggle('visible', visible)

    const inputs = this.bankDetailsTarget.querySelectorAll('input')
    inputs.forEach(input => (input.required = visible))
  }
}
