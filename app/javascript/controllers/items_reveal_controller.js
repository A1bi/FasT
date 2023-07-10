import { Controller } from '@hotwired/stimulus'

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
      if (i > this.revealedItems - 1) {
        item.style.display = 'none'
      } else {
        item.style.removeProperty('display')
      }
    })

    if (this.revealedItems >= this.itemTargets.length) {
      this.revealButtonTarget.style.display = 'none'
    } else {
      this.revealButtonTarget.style.removeProperty('display')
    }
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
