document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('form').forEach(form => {
    form.addEventListener('submit', e => {
      if (e.currentTarget.checkValidity()) return

      e.currentTarget.classList.add('was-validated')
      e.preventDefault()
      e.stopPropagation()
    })
  })
})
