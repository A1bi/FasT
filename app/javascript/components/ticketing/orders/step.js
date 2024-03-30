/* global _paq */

import { addBreadcrumb } from 'components/sentry'

export default class {
  constructor (name, delegate) {
    this.name = name
    this.box = document.querySelector(`.stepCon.${this.name}`)
    this.info = { api: {}, internal: {} }
    this.delegate = delegate
    if (!this.box) return

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
    const form = this.box.querySelector('form')
    if (!form) return

    const formData = new FormData(form)
    for (let [name, value] of formData.entries()) {
      const match = name.match(/\[([a-z_]+)\]/)
      if (!match) continue

      const fieldName = match[1]
      if (!/_confirmation$/.test(fieldName)) {
        if (fieldName === 'affiliation' && ['Herr', 'Frau'].indexOf(value) > -1) {
          value = ''
        }
        this.info.api[fieldName] = value
      }
    }
  }

  getStepInfo (stepName) {
    return this.delegate.info[stepName].internal
  }

  getFieldWithKey (key) {
    return this.box.querySelector(`#${this.name}_${key}`)
  }

  validate () {
    return true
  }

  validateAsync (callback) {
    callback()
  }

  validateField (key, msg, validationProc) {
    const field = this.getFieldWithKey(key)
    this.showErrorOnField(key, !validationProc(field), msg)
  }

  validateFields (beforeProc, afterProc) {
    this.foundErrors = false
    if (beforeProc) beforeProc()

    if (!this.foundErrors) this.updateInfoFromFields()
    if (afterProc) afterProc()

    return !this.foundErrors
  }

  upperStrip (value) {
    return value.toUpperCase().replace(/ /g, '')
  }

  valueNotEmpty (value) {
    return !value.match(/^[\s\t\r\n]*$/)
  }

  valueOnlyDigits (value) {
    return value.match(/^\d*$/)
  }

  valueIsIBAN (value) {
    const parts = this.upperStrip(value)
      .match(/^([A-Z]{2})(\d{2})([A-Z0-9]{6,30})$/)

    if (parts) {
      const country = parts[1]
      const check = parts[2]
      const bban = parts[3]
      let number = bban + country + check

      number = number.replace(/\D/g, char => {
        return char.charCodeAt(0) - 64 + 9
      })

      let remainder = 0
      for (let i = 0; i < number.length; i++) {
        remainder = (remainder + number.charAt(i)) % 97
      }

      if ((country === 'DE' && bban.length !== 18) || remainder !== 1) {
        return false
      }
    } else {
      return false
    }

    return true
  }

  fieldIsEmail (field) {
    return field.value.match(field.pattern)
  }

  showErrorOnField (key, error, msg) {
    const input = this.getFieldWithKey(key)
    input.closest('form').classList.add('was-validated')
    input.setCustomValidity(error ? msg : '')
    input.parentElement.querySelector('.invalid-feedback').textContent = msg

    this.foundErrors = this.foundErrors || error

    this.addBreadcrumb('form error', {
      field: key,
      value: input.value,
      message: msg
    }, 'warn')
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
    return value.toFixed(2).toString().replace('.', ',')
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
