import { Controller } from 'stimulus'
import QRCode from 'qrcode-svg'

import '../../../styles/ticketing/box_office/front_display_controller.sass'

export default class extends Controller {
  static targets = ['tips', 'qrCode']

  initialize () {
    this.currentTipIndex = -1
    this.timeNextTipCycle(0)
    window.setTimeout(() => this.showQrCode('foobar839398'), 1000)
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
