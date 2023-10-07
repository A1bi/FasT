import { colorToHslCss, generateColors } from 'components/dynamic_colors'

const setCSSVariable = (name, value) => {
  document.querySelector(':root').style.setProperty(`--${name}`, value)
}

const shuffleColors = () => {
  const colors = generateColors()

  colors.forEach((color, i) => {
    setCSSVariable(`dynamic-color-${i}`, colorToHslCss(color))
    setCSSVariable(`dynamic-color-${i}-hover`, colorToHslCss(color, 0.8))
    setCSSVariable(`dynamic-color-${i}-active`, colorToHslCss(color, 0.6))
  })

  document.querySelectorAll('hr').forEach(el => {
    el.style.backgroundImage = window.getComputedStyle(el).backgroundImage.replace(/black|hsl\(.+?\)/, colorToHslCss(colors[0]))
  })
}

document.addEventListener('DOMContentLoaded', shuffleColors)

document.addEventListener('keydown', e => {
  if (e.ctrlKey && e.altKey && e.code === 'KeyC') shuffleColors()
})
