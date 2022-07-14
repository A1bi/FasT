import { Controller } from 'stimulus'
import { createSubscription } from '../../../components/actioncable'
import QRCode from 'qrcode-svg'

import '../../../styles/ticketing/box_office/front_display_controller.sass'

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

  subscribe () {
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

  showQrCode (content) {
    const qr = new QRCode({
      content: content,
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
      this.timeNextTipCycle(3000)
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
}
