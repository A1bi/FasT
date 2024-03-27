document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('form').forEach(form => {
    form.addEventListener('submit', e => {
      if (e.currentTarget.checkValidity()) return

      const invalid = e.currentTarget.querySelectorAll(':scope :invalid')
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
        } else {
          message = 'Bitte prüfen Sie Ihre Eingabe.'
        }

        feedback.textContent = message
      })

      e.currentTarget.classList.add('was-validated')
      e.currentTarget.scrollIntoView()
      e.preventDefault()
      e.stopPropagation()
    })
  })
})
