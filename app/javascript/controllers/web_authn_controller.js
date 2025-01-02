import { Controller } from '@hotwired/stimulus'
import {
  create as createCredential,
  parseCreationOptionsFromJSON,
  parseRequestOptionsFromJSON,
  get as authWithCredential
} from '@github/webauthn-json/browser-ponyfill'
import { captureMessage } from 'components/sentry'
import { fetch } from 'components/utils'

export default class extends Controller {
  static values = {
    createOptionsPath: String,
    createPath: String,
    authOptionsPath: String,
    authPath: String
  }

  async create () {
    const optionsResponse = await fetch(this.createOptionsPathValue)
    const options = parseCreationOptionsFromJSON({ publicKey: optionsResponse })

    try {
      const challengeResponse = await createCredential(options)
      await fetch(this.createPathValue, 'POST', { credential: challengeResponse })
      window.location.reload()
    } catch (error) {
      captureMessage(error)
      window.alert('Beim Hinzufügen des Passkeys ist ein Fehler aufgetreten.')
    }
  }

  async auth () {
    const optionsResponse = await fetch(this.authOptionsPathValue)
    const options = parseRequestOptionsFromJSON({ publicKey: optionsResponse })

    const challengeResponse = await authWithCredential(options)
    const res = await fetch(this.authPathValue, 'POST', { credential: challengeResponse })

    window.location = res.goto_path
  }
}
