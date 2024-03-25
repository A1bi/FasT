import { colorToHslCss, generateColors } from 'components/dynamic_colors'

const setCSSVariable = (name, value) => {
  document.querySelector(':root').style.setProperty(`--${name}`, value)
}

const shuffleColors = () => {
  generateColors().forEach((color, i) => {
    setCSSVariable(`shuffled-color-${i}`, colorToHslCss(color))
  })

  const bgColor = window.getComputedStyle(document.querySelector('header')).backgroundColor

  document.querySelectorAll('hr').forEach(el => {
    el.style.backgroundImage = window.getComputedStyle(el).backgroundImage.replace(/black|hsl|rgb\(.+?\)/, bgColor)
  })
}

document.addEventListener('DOMContentLoaded', shuffleColors)

window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', shuffleColors)

document.addEventListener('keydown', e => {
  if (e.ctrlKey && e.altKey && e.code === 'KeyC') shuffleColors()
})
