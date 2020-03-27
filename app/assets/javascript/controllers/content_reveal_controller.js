import { Controller } from 'stimulus'

import '../styles/content_reveal_controller.sass'

export default class extends Controller {
  static targets = ['content']

  reveal () {
    this.element.classList.toggle('revealed')

    const maxHeight = this.contentTarget.scrollHeight
    const style = this.contentTarget.style
    style.maxHeight = `${!parseInt(style.maxHeight) ? maxHeight : 0}px`
  }
}