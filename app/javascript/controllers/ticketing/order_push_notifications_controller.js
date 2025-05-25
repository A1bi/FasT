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

    this.serviceWorkerRegistration = await navigator.serviceWorker.getRegistration('/ticketing_service_worker.js')
    if (!this.serviceWorkerRegistration || !this.serviceWorkerRegistration.active) {
      this.serviceWorkerRegistration = await navigator.serviceWorker.register('/ticketing_service_worker.js')

      if (window.Notification.permission === 'granted') {
        this.subscribe()
      }
    }

    this.updateSelf()
  }

  async requestNotificationsPermission () {
    const result = await window.Notification.requestPermission()
    toggleDisplay(this.buttonTarget, false)
    toggleDisplay(this.spinnerTarget, true)

    if (result === 'granted') {
      await this.subscribe()
    }

    // eslint-disable-next-line no-new
    new Notification(this.successNotificationTitleValue, { body: this.successNotificationBodyValue })
    toggleDisplay(this.spinnerTarget, false)
    this.updateSelf()
  }

  async subscribe () {
    const subscription = await this.serviceWorkerRegistration.pushManager.subscribe({
      applicationServerKey: this.publicKeyValue,
      userVisibleOnly: true
    })

    await fetch(this.apiPathValue, 'post', JSON.stringify(subscription))
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
