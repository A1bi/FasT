/* global _paq */

import { checkFormValidity } from 'components/forms'
import { addBreadcrumb } from 'components/sentry'

export default class {
  constructor (name, delegate) {
    this.name = name
    this.box = document.querySelector(`.stepCon.${this.name}`)
    this.info = { api: {}, internal: {} }
    this.delegate = delegate
    if (!this.box) return
    this.form = this.box.querySelector('form')

    this.box.addEventListener('transitionend', event => {
      if (event.propertyName !== 'left') return

      this.box.classList.remove('step-animating')
    })
  }

  moveIn () {
    this.delegate.setNextBtnText()
    this.willMoveIn()
    this.box.classList.remove('step-left', 'step-right')
    this.box.classList.add('step-current', 'step-animating')
  }

  moveOut (left) {
    this.box.classList.remove('step-current')
    this.box.classList.add(left ? 'step-left' : 'step-right', 'step-animating')
  }

  slideToggle (target, toggle) {
    this.delegate.slideToggle(target, toggle)
  }

  updateInfoFromFields () {
    if (!this.form) return

    const formData = new FormData(this.form)
    for (const [name, value] of formData.entries()) {
      const match = name.match(/\[([a-z_]+)\]/)
      if (!match || /_confirmation$/.test(match[1])) continue

      this.info.api[match[1]] = value
    }
  }

  getStepInfo (stepName) {
    return this.delegate.info[stepName].internal
  }

  validate () {
    if (!this.form) return true

    if (checkFormValidity(this.form)) {
      this.updateInfoFromFields()
      return true
    }

    return false
  }

  validateAsync (callback) {
    callback()
  }

  willMoveIn () {}

  shouldBeSkipped () {
    return false
  }

  needsFullWidth () {
    return false
  }

  nextBtnEnabled () {
    return true
  }

  formatCurrency (value) {
    return `${value.toFixed(2).toString().replace('.', ',')} €`
  }

  trackPiwikGoal (id, revenue) {
    try {
      _paq.push(['trackGoal', id, revenue])
    } catch (e) {}
  }

  addBreadcrumb (message, data, level) {
    addBreadcrumb({
      category: `ordering.${this.name}`,
      message,
      data,
      level
    })
  }
}
