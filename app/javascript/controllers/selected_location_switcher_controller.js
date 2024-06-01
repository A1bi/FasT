import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  switchLocation (select) {
    window.location.href = select.currentTarget.value
  }
}
