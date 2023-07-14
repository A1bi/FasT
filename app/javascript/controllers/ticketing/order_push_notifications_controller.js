import { Controller } from '@hotwired/stimulus'
import { toggleDisplay, fetch } from 'components/utils'

export default class extends Controller {
  static values = {
    publicKey: String,
    apiPath: String
  }

  /* eslint-disable compat/compat */
  async connect () {
    this.updateButton()
    if (!this.supported) return

    this.serviceWorkerRegistration = await navigator.serviceWorker.register('/ticketing_service_worker.js')
  }

  async requestNotificationsPermission () {
    const result = await window.Notification.requestPermission()

    if (result === 'granted') {
      await this.subscribe()
    }

    this.updateButton()
  }

  async subscribe () {
    const subscription = await this.serviceWorkerRegistration.pushManager.subscribe({
      applicationServerKey: this.publicKeyValue,
      userVisibleOnly: true
    })

    await fetch(this.apiPathValue, 'post', JSON.stringify(subscription))
  }

  updateButton () {
    toggleDisplay(this.element, this.supported &&
      window.Notification.permission !== 'granted' &&
      window.Notification.permission !== 'denied')
  }

  get supported () {
    return window.Notification &&
           window.Notification.requestPermission &&
           window.PushManager
  }
}
