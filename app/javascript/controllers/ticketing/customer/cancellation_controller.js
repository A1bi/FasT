import { Controller } from '@hotwired/stimulus'
import { fetch, toggleDisplay, formatCurrency } from 'components/utils'

export default class extends Controller {
  static targets = ['ticketIdCheckbox', 'instructions', 'refundAmountMessage', 'refundAmount', 'refundForm', 'bankDetails', 'submitButton']
  static values = {
    refundUrl: String
  }

  async ticketIdsChanged () {
    this.ticketIds = this.ticketIdCheckboxTargets.filter(t => t.checked).map(t => t.value)
    const anyTickets = this.ticketIds.length > 0

    this.submitButtonTarget.disabled = !anyTickets
    toggleDisplay(this.instructionsTarget, !anyTickets)
    toggleDisplay(this.refundAmountMessageTarget, anyTickets)
    if (!anyTickets) {
      toggleDisplay(this.refundFormTarget, false)
      return
    }

    const refund = await fetch(this.refundUrlValue, 'post', {
      ticket_ids: this.ticketIds
    })
    this.refundAmountTarget.textContent = formatCurrency(refund.amount)
    toggleDisplay(this.refundFormTarget, refund.amount > 0)
  }

  toggleBankDetails (event) {
    const visible = event.currentTarget.value === 'false'
    toggleDisplay(this.bankDetailsTarget, visible)

    const inputs = this.bankDetailsTarget.querySelectorAll(':scope input')
    inputs.forEach(input => { input.disabled = !visible })
  }
}
