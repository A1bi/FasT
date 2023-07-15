import { Controller } from '@hotwired/stimulus'
import { toggleDisplay, fetch } from 'components/utils'

export default class extends Controller {
  static targets = ['spinner', 'button']
  static values = {
    publicKey: String,
    apiPath: String,
    successNotificationTitle: String,
    successNotificationBody: String
  }

  /* eslint-disable compat/compat */
  async connect () {
    if (!this.supported) return

    this.serviceWorkerRegistration = await navigator.serviceWorker.register('/ticketing_service_worker.js')
    this.updateSelf()
  }

  async requestNotificationsPermission () {
    const result = await window.Notification.requestPermission()
    toggleDisplay(this.buttonTarget, false)

    if (result === 'granted') {
      await this.subscribe()
    }

    this.updateSelf()
  }

  async subscribe () {
    toggleDisplay(this.spinnerTarget, true)

    const subscription = await this.serviceWorkerRegistration.pushManager.subscribe({
      applicationServerKey: this.publicKeyValue,
      userVisibleOnly: true
    })

    await fetch(this.apiPathValue, 'post', JSON.stringify(subscription))

    // eslint-disable-next-line no-new
    new Notification(this.successNotificationTitleValue, { body: this.successNotificationBodyValue })
    toggleDisplay(this.spinnerTarget, false)
  }

  updateSelf () {
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
