import { Controller } from '@hotwired/stimulus'
import { loadVendorStylesheet } from 'components/utils'

export default class extends Controller {
  static targets = ['filePond']
  static values = {
    vendorStylesheetPaths: Array
  }

  currentIndex = -1

  async connect () {
    const { create, registerPlugin } = await import('filepond')
    const { default: FilePondPluginImagePreview } = await import('filepond-plugin-image-preview')
    const { default: FilePondPluginFileValidateType } = await import('filepond-plugin-file-validate-type')

    registerPlugin(
      FilePondPluginImagePreview,
      FilePondPluginFileValidateType
    )

    this.vendorStylesheetPathsValue.forEach(path => loadVendorStylesheet(path))

    create(this.filePondTarget, {
      server: {
        process: {
          url: this.data.get('photos-path'),
          method: this.isEdit ? 'PATCH' : 'POST',
          headers: {
            'X-CSRF-TOKEN': this.csrfToken
          }
        }
      },
      allowReorder: false,
      allowRevert: false,
      allowRemove: false,
      allowProcess: false,
      credits: {}
    })
  }

  get csrfToken () {
    return document.querySelector('meta[name="csrf-token"]').getAttribute('content')
  }

  get isEdit () {
    return this.element.hasAttribute('data-photos-edit')
  }
}
