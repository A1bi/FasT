import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['content', 'expandButton']

  connect () {
    const initialHeight = this.contentTarget.clientHeight
    const offset = this.hasExpandButtonTarget ? this.expandButtonTarget.scrollHeight * 2 : 0
    if (initialHeight + offset > this.contentTarget.scrollHeight) {
      this.expand()
    }

    this.contentTarget.addEventListener('transitionend', () => {
      this.element.classList.remove('expanding')
      this.element.classList.add('expanded')
    })
  }

  expand () {
    this.element.classList.add('expanding')
  }
}
