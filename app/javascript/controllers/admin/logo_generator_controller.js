import { Controller } from '@hotwired/stimulus'
import { colorToRgbCss, decimalsToHex, generateColors } from 'components/dynamic_colors'

export default class extends Controller {
  static targets = ['color', 'dominantColors', 'logos']

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

  selectDominantColor (i) {
    const ii = this.selectedDominantColorIndexes.indexOf(i)
    if (ii > -1) {
      this.selectedDominantColorIndexes.splice(ii, 1)
    } else {
      this.selectedDominantColorIndexes.push(i)
      if (this.selectedDominantColorIndexes.length > this.colorTargets.length) {
        this.selectedDominantColorIndexes.shift()
      }
    }

    const colorBoxes = this.dominantColorsTarget.querySelectorAll('.color')
    colorBoxes.forEach((colorBox, j) => {
      const selected = this.selectedDominantColorIndexes.indexOf(j) > -1
      colorBox.classList.toggle('selected', selected)
    })

    this.selectedDominantColorIndexes.forEach((index, i) => {
      this.colors[i] = colorBoxes[index].dataset.color
    })

    this.updateColorInputs()
    this.updateLogos()
  }

  async determineDominantColorsFromFile (event) {
    const { default: ColorThief } = await import('https://unpkg.com/colorthief@2.4.0/dist/color-thief.mjs')
    const thief = new ColorThief()
    const image = await this.loadImageFromInput(event.target)
    const colors = thief.getPalette(image, 10, 1)

    this.selectedDominantColorIndexes = []

    this.dominantColorsTarget.innerHTML = ''
    colors.forEach((color, i) => {
      const colorCirle = document.createElement('div')
      colorCirle.classList.add('color')
      colorCirle.addEventListener('click', () => this.selectDominantColor(i))
      colorCirle.dataset.color = decimalsToHex(color)
      colorCirle.style.backgroundColor = colorCirle.dataset.color
      this.dominantColorsTarget.appendChild(colorCirle)

      if (i < this.colorTargets.length) {
        this.selectDominantColor(i)
      }
    })
  }

  async loadImageFromInput (input) {
    return new Promise((resolve) => {
      const reader = new FileReader()
      reader.onload = () => {
        const image = new Image()
        image.src = reader.result
        image.onload = () => resolve(image)
      }
      reader.readAsDataURL(input.files[0])
    })
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
