import $ from 'jquery'

import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['action', 'reason']

  initialize () {
    this.toggleReason()
  }

  toggleReason () {
    this.reasonTarget.style.display =
      this.actionTarget.value === 'cancel' ? 'inline' : 'none'
  }

  submit () {
    const $this = $(this.element)
    const current = $this.find(':selected')
    const method = current.data('method')
    $this.data('confirm', current.data('confirm'))
      .prop('action', current.data('path'))
      .find('input[name=_method]').val(method)
    $this.prop('method', (method === 'get') ? method : 'post')
  }
}
