import { Controller } from '@hotwired/stimulus'
import { loadVendorStylesheet } from '../components/utils'
import { create, registerPlugin } from 'filepond'
import FilePondPluginImagePreview from 'filepond-plugin-image-preview'
import FilePondPluginFileValidateType from 'filepond-plugin-file-validate-type'

export default class extends Controller {
  static targets = ['filePond'];

  currentIndex = -1;

  initialize () {
    registerPlugin(
      FilePondPluginImagePreview,
      FilePondPluginFileValidateType
    )
  }

  connect () {
    loadVendorStylesheet('filepond')
    loadVendorStylesheet('filepond-plugin-image-preview')

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
