/* global _paq */

import { addBreadcrumb } from '@sentry/browser'
import $ from 'jquery'

export default class {
  constructor (name, delegate) {
    this.name = name
    this.box = $(`.stepCon.${this.name}`)
    this.info = { api: {}, internal: {} }
    this.delegate = delegate
  }

  moveIn (animate) {
    this.delegate.setNextBtnText()
    this.willMoveIn()

    animate = animate !== false

    this.box.show()
    const props = { left: '0%' }
    if (animate) {
      this.box.animate(props, this.didMoveIn.bind(this))
    } else {
      this.box.css(props)
      this.didMoveIn()
    }
    this.resizeDelegateBox(animate)
  }

  moveOut (left) {
    this.box.animate({ left: 100 * ((left) ? -1 : 1) + '%' }, box => {
      $(box).hide()
    })
  }

  resizeDelegateBox (animated) {
    if (this.box.is(':visible')) {
      this.delegate.resizeStepBox(this.box.outerHeight(true), animated)
    }
  }

  slideToggle (obj, toggle) {
    const props = {
      step: () => this.resizeDelegateBox(false)
    }

    if (toggle) {
      obj.slideDown(props)
    } else {
      obj.slideUp(props)
    }

    return obj
  }

  updateInfoFromFields () {
    const fields = this.box.find('form').serializeArray()
    for (const field of fields) {
      const name = field.name.match(/\[([a-z_]+)\]/)
      if (!!name && !/_confirmation$/.test(name[1])) {
        if (name[1] === 'affiliation' && ['Herr', 'Frau'].indexOf(field.value) > -1) {
          field.value = ''
        }
        this.info.api[name[1]] = field.value
      }
    }
  }

  getStepInfo (stepName) {
    return this.delegate.info[stepName].internal
  }

  getFieldWithKey (key) {
    return this.box.find(`#${this.name}_${key}`)
  }

  validate () {
    return true
  }

  validateAsync (callback) {
    callback()
  }

  validateField (key, error, validationProc) {
    const field = this.getFieldWithKey(key)
    if (!validationProc(field)) {
      this.showErrorOnField(key, error)
    }
  }

  validateFields (beforeProc, afterProc) {
    this.box.find('tr').removeClass('error')
    this.foundErrors = false
    beforeProc()

    if (this.foundErrors) {
      this.resizeDelegateBox(true)
    } else {
      this.updateInfoFromFields()
    }
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
    return field.val().match(field.attr('pattern'))
  }

  showErrorOnField (key, msg) {
    const input = this.getFieldWithKey(key)
    const field = input.parents('tr').addClass('error')
    if (msg) field.find('.msg').html(msg)
    this.foundErrors = true

    this.addBreadcrumb('form error', {
      field: key,
      value: input.val(),
      message: msg
    }, 'warn')
  }

  willMoveIn () {}

  didMoveIn () {}

  shouldBeSkipped () {
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
      message: message,
      data: data,
      level: level
    })
  }

  registerEventAndInitiate (elements, event, proc) {
    elements.on(event, event => proc($(event.currentTarget)))
    elements.each((_, element) => proc($(element)))
  }
}
