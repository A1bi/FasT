import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  selectEvent (select) {
    const slug = select.currentTarget.value
    window.location.href = this.element.dataset.eventUrl.replace(':slug', slug)
  }
}
