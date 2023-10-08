import { Controller } from '@hotwired/stimulus'
import { colorToRgbCss, generateColors } from 'components/dynamic_colors'

export default class extends Controller {
  static targets = ['color', 'logos']

  connect () {
    this.shuffleColors()
  }

  shuffleColors () {
    const colors = generateColors().slice(1)
    this.colors = colors.map(color => colorToRgbCss(color))

    this.updateColorInputs()
    this.updateLogos()
  }

  rotateColors () {
    this.colors.unshift(this.colors.pop())

    this.updateColorInputs()
    this.updateLogos()
  }

  downloadSvg (event) {
    const svg = event.target.closest('.col').querySelector('svg')
    const data = `<?xml version="1.0" standalone="no"?>\r\n${svg.outerHTML}`
    const url = `data:image/svg+xml;charset=utf-8,${encodeURIComponent(data)}`
    const link = document.createElement('a')
    link.download = 'logo.svg'
    link.href = url
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
  }

  updateColorInputs () {
    this.colorTargets.forEach((color, i) => {
      color.value = this.colors[i]
    })
  }

  setColorsFromInputs () {
    this.colors = this.colorTargets.map(target => target.value)
    this.updateLogos()
  }

  updateLogos () {
    const logos = this.logosTarget.querySelectorAll('svg')
    logos.forEach(logo => {
      logo.querySelectorAll(':scope > g').forEach((group, i) => {
        group.style.fill = this.colors[i % this.colors.length]
      })
    })
  }
}
