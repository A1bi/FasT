import { Controller } from '@hotwired/stimulus'
import { createSubscription } from 'components/actioncable'

export default class extends Controller {
  static targets = ['checkedIn', 'sold']

  initialize () {
    this.subscribe()
  }

  async subscribe () {
    this.subscription = createSubscription({
      channel: 'Ticketing::CheckInsChannel'
    }, {
      received: data => this.update(data)
    })
  }

  update (data) {
    this.checkedInTarget.innerText = data.checked_in
    this.soldTarget.innerText = data.sold
  }
}
