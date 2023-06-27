const colorToHslCss = (color, brightness) => {
  let [h, s, v] = color
  h /= 360
  s /= 360
  v /= 360

  const l = v * (1 - (s / 2))
  s = (l === 0 || l === 1) ? 0 : ((v - l) / Math.min(l, 1 - l))

  return `hsl(${h * 360}deg ${s * 100}% ${l * 100}%)`
}

const setCSSVariable = (name, value) => {
  document.querySelector(':root').style.setProperty(`--${name}`, value)
}

const generateColors = () => {
  const numColors = 4
  const colors = []

  // set huegb, avoid browns
  const huebg = Math.random() * 360
  const prevHues = []
  const prevColors = []

  // avoid colors to close to huebg
  for (let i = 0; i < numColors; i++) {
    let huelogo = Math.random() * 360
    while (Math.abs(huelogo - huebg) < 60 || (huelogo > 30 && huelogo < 80)) {
      huelogo = Math.random() * 360
    }

    // check if huelogo is close to prev. huelogos, then colapse colors
    let closestColor = 0
    let closestDist = 1000
    for (let j = 0; j < i; j++) {
      const dist = Math.min(Math.abs(huelogo - prevHues[j]), 360 - Math.abs(huelogo - prevHues[j]))
      if (dist < 50 && dist < closestDist) {
        closestDist = dist
        closestColor = prevColors[j]
      }
    }
    if (closestDist < 30) {
      colors[i] = closestColor
    } else {
      colors[i] = [huelogo, 230, 360]
    }

    prevHues[i] = huelogo
    prevColors[i] = colors[i]
  }

  colors.unshift([huebg, 70, 320])

  return colors
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
