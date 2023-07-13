import { Controller } from '@hotwired/stimulus'
import { toggleDisplay } from 'components/utils'

export default class extends Controller {
  static targets = ['note', 'amount', 'bankDetails']

  initialize () {
    this.toggleAmount()
    this.toggleBankDetails()
  }

  toggleAmount () {
    this.toggleForNote(this.amountTarget, 'correction')
  }

  toggleBankDetails () {
    this.toggleForNote(this.bankDetailsTarget, 'refund_to_new_bank_account')
  }

  toggleForNote (target, value) {
    toggleDisplay(target, this.noteTarget.value === value)
  }
}
