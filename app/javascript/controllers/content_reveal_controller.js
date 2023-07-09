import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['content']

  connect () {
    this.contentTarget.addEventListener('transitionend', () => {
      this.element.classList.remove('transitioning')
    })
  }

  reveal () {
    this.element.classList.toggle('revealed')
    this.element.classList.add('transitioning')

    const maxHeight = this.contentTarget.scrollHeight
    const style = this.contentTarget.style
    style.maxHeight = `${!parseInt(style.maxHeight) ? maxHeight : 0}px`
  }
}
