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
  static targets = ['autofill']
  static values = {
    createOptionsPath: String,
    createPath: String,
    authOptionsPath: String,
    authPath: String,
    autofill: Boolean,
    activationToken: String
  }

  async connect () {
    if (this.autofillValue && await this.isConditionalMediationAvailable()) {
      this.auth(true)
    }
  }

  async create () {
    const optionsResponse = await fetch(this.createOptionsPathValue, 'GET', {
      activation_token: this.activationTokenValue
    })
    const options = parseCreationOptionsFromJSON({ publicKey: optionsResponse })
    let challengeResponse

    try {
      challengeResponse = await createCredential(options)
    } catch (e) {
      if (e.name !== 'NotAllowedError') captureMessage(e)
      return
    }

    const res = await fetch(this.createPathValue, 'POST', {
      credential: challengeResponse,
      activation_token: this.activationTokenValue
    })

    if (this.activationTokenValue) {
      window.location = res.goto_path
    } else {
      window.location.reload()
    }
  }

  async auth (conditionalMediation) {
    if (this.abortController) this.abortController.abort()
    this.abortController = new AbortController()
    const optionsResponse = await fetch(this.authOptionsPathValue)
    const options = parseRequestOptionsFromJSON({
      publicKey: optionsResponse,
      signal: this.abortController.signal,
      // conditionalMediation might be an event object (Stimulus action), therefore we check === true
      mediation: conditionalMediation === true ? 'conditional' : 'optional'
    })
    let challengeResponse

    try {
      challengeResponse = await authWithCredential(options)
    } catch (e) {
      if (e.name !== 'AbortError' && e.name !== 'NotAllowedError') captureMessage(e)
      return
    }

    try {
      const res = await fetch(this.authPathValue, 'POST', { credential: challengeResponse })
      window.location = res.goto_path
    } catch (e) {
      window.location.reload()
    }
  }

  async isConditionalMediationAvailable () {
    if (!window.PublicKeyCredential?.isConditionalMediationAvailable) {
      return Promise.resolve(false)
    }

    // eslint-disable-next-line compat/compat
    return window.PublicKeyCredential.isConditionalMediationAvailable()
  }
}
