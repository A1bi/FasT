import { Controller } from '@hotwired/stimulus'
import { fetch } from 'components/utils'

export default class extends Controller {
  static targets = ['item']
  static values = {
    submitPath: String
  }

  async connect () {
    const { Sortable } = await import('sortablejs')

    Sortable.create(this.element, {
      handle: '.sortable-handle',
      onUpdate: () => this.submitPositions()
    })
  }

  submitPositions () {
    const ids = this.itemTargets.map(item => item.dataset.sortableId)
    const data = { ids }
    fetch(this.submitPathValue, 'put', data)
  }
}
