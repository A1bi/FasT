import { Controller } from 'stimulus'

export default class extends Controller {
  switchTable (e) {
    const tableToShow = e.currentTarget.value

    document.querySelectorAll('.stats-table').forEach(el => {
      el.classList.toggle('d-none', !el.classList.contains(tableToShow))
    })
  }
}
