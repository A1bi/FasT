import { Controller } from '@hotwired/stimulus'
import SeatingStandalone from 'components/ticketing/seating_standalone'

export default class extends Controller {
  connect () {
    if (this.data.get('mode') === 'standalone') {
      this.seating = new SeatingStandalone(this.element)
      this.seating.init()
    }
  }
}
