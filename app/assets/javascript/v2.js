const colorToHslCss = (color, brightness) => {
  return `hsl(${color[0]}deg ${color[1]}% ${color[2] * (brightness || 1)}%)`
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
  for (var i = 0; i < numColors; i++) {
    var huelogo = Math.random() * 360
    while (Math.abs(huelogo - huebg) < 60 || (huelogo > 30 && huelogo < 80)) {
      huelogo = Math.random() * 360
    }

    // check if huelogo is close to prev. huelogos, then colapse colors
    var closestColor = 0
    var closestDist = 1000
    for (var j = 0; j < i; j++) {
      const dist = Math.min(Math.abs(huelogo - prevHues[j]), 360 - Math.abs(huelogo - prevHues[j]))
      if (dist < 50 && dist < closestDist) {
        closestDist = dist
        closestColor = prevColors[j]
      }
    }
    if (closestDist < 30) {
      colors[i] = closestColor
    } else {
      colors[i] = [huelogo, 63.89, 60]
    }

    prevHues[i] = huelogo
    prevColors[i] = colors[i]

    console.log(`colors[${i}] = ${colors[i]}`)
  }

  colors.unshift([huebg, 19.44, 88.89])

  return colors
}

const toggleMenu = (toggle) => {
  document.body.classList.toggle('menu-active', toggle)
  const active = document.body.classList.contains('menu-active')
  const height = active ? document.querySelector('nav ul').offsetHeight : 0
  document.querySelector('nav').style.height = `${height}px`
}

var colors = generateColors()

document.addEventListener('DOMContentLoaded', () => {
  colors.forEach((color, i) => {
    setCSSVariable(`dynamic-color-${i}`, colorToHslCss(color))
    setCSSVariable(`dynamic-color-${i}-hover`, colorToHslCss(color, 0.8))
    setCSSVariable(`dynamic-color-${i}-active`, colorToHslCss(color, 0.6))
  })

  document.querySelectorAll('hr').forEach(el => {
    el.style.backgroundImage = window.getComputedStyle(el).backgroundImage.replace('black', colorToHslCss(colors[0]))
  })

  document.querySelector('.menu-toggle').addEventListener('click', () => {
    toggleMenu()
  })

  window.addEventListener('click', e => {
    if (e.target.matches('.menu-toggle') || document.querySelector('nav').contains(e.target)) return

    toggleMenu(false)
  })

  document.addEventListener('keydown', e => {
    if (e.key === 'Escape') toggleMenu(false)
  })
})
