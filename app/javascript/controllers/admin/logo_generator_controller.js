import { Controller } from '@hotwired/stimulus'
import { colorToRgbCss, generateColors } from 'components/dynamic_colors'

export default class extends Controller {
  static targets = ['color', 'logos']

  shuffleColors () {
    let colors = generateColors().slice(1)
    colors = colors.map(color => colorToRgbCss(color))

    this.colorTargets.forEach((color, i) => {
      color.value = colors[i]
    })

    this.updateLogosWithColors(colors)
  }

  updateLogosWithColorInputs () {
    this.updateLogosWithColors(this.colorTargets.map(target => target.value))
  }

  updateLogosWithColors (colors) {
    const logos = this.logosTarget.querySelectorAll('svg')
    logos.forEach(logo => {
      logo.querySelectorAll(':scope > g').forEach((group, i) => {
        group.style.fill = colors[i % colors.length]
      })
    })
  }
}
