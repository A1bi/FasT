import { Controller } from 'stimulus'

export default class extends Controller {
  connect () {
    this.element.addEventListener('click', event => {
      if (event.target.matches('input')) return
      window.location = this.data.get('path')
    })
  }
}
