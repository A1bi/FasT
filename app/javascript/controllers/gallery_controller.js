import { Controller } from '@hotwired/stimulus'
import { loadVendorStylesheet } from 'components/utils'

export default class extends Controller {
  static values = {
    vendorStylesheetPath: String
  }

  async connect () {
    loadVendorStylesheet(this.vendorStylesheetPathValue)

    const GLightbox = (await import('glightbox')).default

    GLightbox({
      selector: '.gallery .photo a'
    })
  }
}
