import { Controller } from 'stimulus'
import { toggleDisplay } from '../../components/utils'

export default class extends Controller {
  static targets = ['note', 'amount']

  initialize () {
    this.toggleAmount()
  }

  toggleAmount () {
    toggleDisplay(this.amountTarget, this.noteTarget.value === 'correction', 'inline')
  }
}
