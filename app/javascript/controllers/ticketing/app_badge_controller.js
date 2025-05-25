import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  async connect () {
    this.serviceWorkerRegistration = await navigator.serviceWorker.register('/ticketing_service_worker.js')

    document.addEventListener('visibilitychange', () => {
      if (!document.hidden) this.openedApp()
    })

    this.openedApp()
  }

  openedApp () {
    if (!this.serviceWorkerRegistration.active) return

    this.serviceWorkerRegistration.active.postMessage('opened_app')
  }
}
