import { Controller } from 'stimulus'

import '../../../styles/ticketing/box_office/front_display_controller.sass'

export default class extends Controller {
  static targets = ['tips']

  initialize () {
    this.currentTipIndex = -1
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
