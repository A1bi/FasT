export const checkFormValidity = form => {
  const ibanField = form.querySelector('[data-validate-iban]')
  if (ibanField) {
    const message = 'Die angegebene IBAN ist nicht korrekt. Bitte überprüfen Sie sie noch einmal.'
    ibanField.setCustomValidity(valueIsIBAN(ibanField.value) ? '' : message)
  }

  if (form.checkValidity()) return true

  const invalid = form.querySelectorAll(':scope :invalid')
  invalid.forEach(input => {
    const feedback = input.parentNode.querySelector('.invalid-feedback')
    if (!feedback) return

    let message
    if (input.validity.valueMissing) {
      message = 'Bitte füllen Sie dieses Feld aus.'
    } else if (input.validity.typeMismatch || input.validity.patternMismatch) {
      message = input.title || 'Ihre Eingabe ist nicht korrekt.'
    } else if (input.validity.tooLong) {
      message = 'Ihre Eingabe ist zu lang.'
    } else if (input.validity.customError) {
      message = input.validationMessage
    } else {
      message = 'Bitte prüfen Sie Ihre Eingabe.'
    }

    feedback.textContent = message
  })

  form.classList.add('was-validated')

  // scrollIntoView does not work, it scrolls only the parent container because of the height constraint
  window.scrollTo({ top: invalid[0].offsetTop - 100, behavior: 'smooth' })

  return false
}

export const checkFormValidityOnSubmit = () => {
  document.addEventListener('DOMContentLoaded', () => {
    document.querySelectorAll('form').forEach(form => {
      form.addEventListener('submit', e => {
        if (checkFormValidity(e.currentTarget)) return

        e.preventDefault()
        e.stopPropagation()
      })
    })
  })
}

const upperStrip = value => {
  return value.toUpperCase().replace(/ /g, '')
}

const valueIsIBAN = value => {
  const parts = upperStrip(value).match(/^([A-Z]{2})(\d{2})([A-Z0-9]{6,30})$/)

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
