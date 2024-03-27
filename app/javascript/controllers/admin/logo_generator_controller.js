import { Controller } from '@hotwired/stimulus'
import { colorToRgbCss, decimalsToHex, generateColors } from 'components/dynamic_colors'
import { toggleDisplay } from 'components/utils'

export default class extends Controller {
  static targets = ['color', 'dominantColors', 'logos', 'spinner']

  connect () {
    this.shuffleColors()
    this.spinnerVisible = false
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

    const colorBoxes = this.dominantColorsTarget.querySelectorAll(':scope .color')
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
    this.spinnerVisible = true

    const { default: ColorThief } = await import('colorthief')
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

    this.spinnerVisible = false
  }

  async loadImageFromInput (input) {
    return new Promise((resolve) => {
      const file = input.files[0]
      const reader = new FileReader()
      reader.onload = async () => {
        const image = new Image()
        image.onload = () => resolve(image)

        if (file.type.match('pdf')) {
          image.src = await this.convertPdfToImage(reader.result)
        } else {
          image.src = reader.result
        }
      }
      reader.readAsDataURL(file)
    })
  }

  async convertPdfToImage (file) {
    const PDFJS = await import('pdfjs')
    const PDFJSworker = await import('pdfjs-worker')
    PDFJS.GlobalWorkerOptions.workerSrc = PDFJSworker

    const pdf = await PDFJS.getDocument(file).promise
    const page = await pdf.getPage(1)
    const viewport = page.getViewport({ scale: 1 })
    const canvas = document.createElement('canvas')
    const context = canvas.getContext('2d')
    canvas.height = viewport.height
    canvas.width = viewport.width
    await page.render({ canvasContext: context, viewport }).promise
    return canvas.toDataURL('image/png')
  }

  downloadSvg (event) {
    const svg = event.target.closest('.logo').querySelector('svg')
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
    const logos = this.logosTarget.querySelectorAll(':scope svg')
    logos.forEach(logo => {
      logo.querySelectorAll(':scope > g').forEach((group, i) => {
        group.style.fill = this.colors[i % this.colors.length]
      })
    })
  }

  // eslint-disable-next-line accessor-pairs
  set spinnerVisible (toggle) {
    toggleDisplay(this.spinnerTarget, toggle)
  }
}
