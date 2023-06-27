import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['tips', 'qrCode']

  initialize () {
    this.currentTipIndex = -1
    this.receiptUrl = this.data.get('receipt-url')
    this.subscribe()
    this.timeNextTipCycle(0)
  }

  cycleTips () {
    if (this.currentTip) {
      this.currentTip.classList.remove('visible')

      this.afterCurrentTransition(() => {
        this.showNextTip()
      })
    } else {
      this.showNextTip()
    }
  }

  async subscribe () {
    const { createSubscription } = await import('components/actioncable')

    this.subscription = createSubscription({
      channel: 'Ticketing::BoxOffice::FrontDisplayChannel',
      box_office_id: '1'
    }, {
      received: data => this.processPurchase(data)
    })
  }

  processPurchase (info) {
    const url = this.receiptUrl.replace('#token#', info.token)
    this.showQrCode(url)
  }

  async showQrCode (content) {
    const QRCode = await import('qrcode-svg')

    const qr = new QRCode({
      content,
      join: true,
      padding: 0,
      container: 'svg-viewbox'
    })

    this.qrCodeTarget.querySelector('.code').outerHTML = qr.svg()
    this.qrCodeTarget.querySelector('svg').classList.add('code')
    this.qrCodeTarget.classList.add('visible')

    window.clearTimeout(this.qrCodeHideTimer)
    this.qrCodeHideTimer = window.setTimeout(() => {
      this.qrCodeTarget.classList.remove('visible')
    }, 60000)
  }

  showNextTip () {
    this.currentTipIndex = (this.currentTipIndex + 1) % this.tipsTargets.length
    this.currentTip = this.tipsTargets[this.currentTipIndex]
    this.currentTip.classList.add('visible')

    if (this.tipsTargets.length < 2) return

    this.afterCurrentTransition(() => {
      this.timeNextTipCycle(10000)
    })
  }

  afterCurrentTransition (callback) {
    const finished = () => {
      this.currentTip.removeEventListener('transitionend', finished)
      callback()
    }

    this.currentTip.addEventListener('transitionend', finished)
  }

  timeNextTipCycle (delay) {
    window.setTimeout(this.cycleTips.bind(this), delay)
  }

  toggleFullscreen () {
    if (document.fullscreen || document.webkitIsFullScreen) {
      if (document.exitFullscreen) {
        document.exitFullscreen()
      } else if (document.webkitExitFullscreen) {
        document.webkitExitFullscreen()
      }
    } else {
      if (this.element.requestFullscreen) {
        this.element.requestFullscreen()
      } else if (this.element.webkitRequestFullscreen) {
        this.element.webkitRequestFullscreen()
      }
    }
  }
}
