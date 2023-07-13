import { Controller } from '@hotwired/stimulus'
import { toggleDisplay } from 'components/utils'

export default class extends Controller {
  static targets = ['item', 'revealButton']
  static values = {
    initialItems: Number,
    revealStep: Number
  }

  connect () {
    this.revealedItems = this.initialItemsValue
    this.updateItemsAndButton()
  }

  updateItemsAndButton () {
    this.itemTargets.forEach((item, i) => {
      toggleDisplay(item, i < this.revealedItems)
    })

    toggleDisplay(this.revealButtonTarget, this.revealedItems < this.itemTargets.length)
  }

  revealMore () {
    if (this.revealStepValue) {
      this.revealedItems += this.revealStepValue
    } else {
      this.revealedItems = this.itemTargets.length
    }

    this.updateItemsAndButton()
  }
}
