import { Controller } from 'stimulus'

export default class extends Controller {
  switchTable (event) {
    const options = this.element.querySelectorAll('.chooser span')
    options.forEach(option => option.classList.remove('selected'))
    event.currentTarget.classList.add('selected')

    const tableToShow = event.currentTarget.dataset.table
    this.element.querySelectorAll('.table').forEach(table => {
      table.classList.toggle('active', table.classList.contains(tableToShow))
    })
  }
}
