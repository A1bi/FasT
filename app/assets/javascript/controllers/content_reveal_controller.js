import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['content']

  connect () {
    if (this.element.hasAttribute('data-revealed')) {
      setTimeout(() => this.reveal())
    }
  }

  reveal () {
    this.element.classList.toggle('revealed')

    const maxHeight = this.contentTarget.scrollHeight
    const style = this.contentTarget.style
    style.maxHeight = `${!parseInt(style.maxHeight) ? maxHeight : 0}px`
  }
}
