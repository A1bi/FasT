import { Controller } from '@hotwired/stimulus'
import { create, registerPlugin } from 'filepond'
import FilePondPluginImagePreview from 'filepond-plugin-image-preview'
import FilePondPluginFileValidateType from 'filepond-plugin-file-validate-type'

import 'filepond/dist/filepond.min.css'
import 'filepond-plugin-image-preview/dist/filepond-plugin-image-preview.css'

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
