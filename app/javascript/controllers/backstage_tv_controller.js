import { Controller } from '@hotwired/stimulus'
import { colorToRgbCss, generateColors } from 'components/dynamic_colors'
import { toggleDisplay } from 'components/utils'
import moment from 'moment/min/moment-with-locales'

export default class extends Controller {
  static targets = ['admissionIn', 'admissionInTime', 'beginsIn', 'beginsInTime', 'seating', 'clock', 'logo']
  static values = {
    admissionDate: String,
    beginDate: String
  }

  initialize () {
    moment.locale('de')
    moment.relativeTimeThreshold('ss', 0)

    this.admissionDate = moment(this.admissionDateValue)
    this.beginDate = moment(this.beginDateValue)

    this.updateTimes()
    this.shuffleLogoColors()

    if (this.beginDate.isAfter()) {
      this.toggleBottomBar(true)
    }
  }

  updateTimes () {
    const current = new Date()
    this.clockTarget.innerText = current.toLocaleTimeString('de-DE')

    toggleDisplay(this.admissionInTarget, this.admissionDate.isAfter())
    toggleDisplay(this.beginsInTarget, this.admissionDate.isBefore())

    if (this.beginDate.isBefore()) {
      this.beginsInTimeTarget.innerText = 'jetzt'
      setTimeout(() => this.toggleBottomBar(false), 10000)
    } else if (this.admissionDate.isBefore()) {
      this.beginsInTimeTarget.innerText = this.beginDate.fromNow()
    } else {
      this.admissionInTimeTarget.innerText = this.admissionDate.fromNow()
    }

    setTimeout(() => this.updateTimes(), 1000)
  }

  toggleBottomBar (toggle) {
    this.element.classList.toggle('bottom-bar-visible', toggle)
  }

  shuffleLogoColors () {
    const colors = generateColors().slice(1)
    this.colors = colors.map(color => colorToRgbCss(color))

    this.updateLogo()
    setTimeout(() => this.shuffleLogoColors(), 60000)
  }

  updateLogo () {
    const logo = this.logoTarget.querySelector('svg')
    logo.querySelectorAll(':scope > g').forEach((group, i) => {
      group.style.fill = this.colors[i % this.colors.length]
    })
  }

  toggleFullscreen () {
    if (document.fullscreen) {
      document.exitFullscreen()
    } else {
      this.element.requestFullscreen()
    }
  }
}
