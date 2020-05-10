import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['note', 'amount']

  initialize () {
    this.toggleAmount()
  }

  toggleAmount () {
    this.amountTarget.style.display =
      this.noteTarget.value === 'correction' ? 'inline' : 'none'
  }
}
