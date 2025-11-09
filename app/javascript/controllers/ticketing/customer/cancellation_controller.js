import { Controller } from '@hotwired/stimulus'
import { fetch, toggleDisplay, formatCurrency } from 'components/utils'

export default class extends Controller {
  static targets = ['ticketIdCheckbox', 'instructions', 'refundAmountMessage', 'refundAmountPositive',
                    'refundAmountNegative', 'refundAmount', 'refundForm', 'newBankDetailsButton',
                    'bankDetails', 'submitButton']
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
    const amount = formatCurrency(Math.abs(refund.refund_amount))
    this.refundAmountTargets.forEach(target => { target.textContent = amount })
    const positive = (refund.cancelled_value === 0 && refund.refund_amount === 0) || refund.refund_amount > 0
    toggleDisplay(this.refundAmountPositiveTarget, positive)
    toggleDisplay(this.refundAmountNegativeTarget, !positive)

    const formEnabled = refund.refund_amount > 0
    toggleDisplay(this.refundFormTarget, formEnabled)
    this.toggleFormInputs(this.refundFormTarget, formEnabled)
    this.toggleBankDetails()
  }

  toggleBankDetails () {
    toggleDisplay(this.bankDetailsTarget, this.newBankDetailsButtonTarget.checked)
    this.toggleFormInputs(this.bankDetailsTarget, this.newBankDetailsButtonTarget.checked)
  }

  toggleFormInputs (scope, toggle) {
    const inputs = scope.querySelectorAll(':scope input')
    inputs.forEach(input => { input.disabled = !toggle })
  }
}
