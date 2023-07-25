import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect () {
    const img = this.element.querySelector('img')
    this.togglePlaceholder(!img.complete)
    if (!img.complete) img.addEventListener('load', () => this.togglePlaceholder(false))
  }

  togglePlaceholder (toggle) {
    this.element.classList.toggle('photo-loading', toggle)
  }
}
