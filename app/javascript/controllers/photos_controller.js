import { Controller } from '@hotwired/stimulus'
import { loadVendorStylesheet, getAuthenticityToken } from 'components/utils'

export default class extends Controller {
  static targets = ['filePond']
  static values = {
    vendorStylesheetPaths: Array
  }

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
            'X-CSRF-TOKEN': getAuthenticityToken()
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

  get isEdit () {
    return this.element.hasAttribute('data-photos-edit')
  }
}
