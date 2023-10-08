const colorToHsv = (color) => {
  return color.map(c => c / 360)
}

export const colorToHslCss = (color, brightness) => {
  let [h, s, v] = colorToHsv(color)

  const l = v * (1 - (s / 2))
  s = (l === 0 || l === 1) ? 0 : ((v - l) / Math.min(l, 1 - l))

  return `hsl(${h * 360}deg ${s * 100}% ${l * 100}%)`
}

export const colorToRgbCss = (color) => {
  const [h, s, v] = colorToHsv(color)
  let r, g, b

  const i = Math.floor(h * 6)
  const f = h * 6 - i
  const p = v * (1 - s)
  const q = v * (1 - f * s)
  const t = v * (1 - (1 - f) * s)

  switch (i % 6) {
    case 0: r = v; g = t; b = p; break
    case 1: r = q; g = v; b = p; break
    case 2: r = p; g = v; b = t; break
    case 3: r = p; g = q; b = v; break
    case 4: r = t; g = p; b = v; break
    case 5: r = v; g = p; b = q; break
  }

  return decimalsToHex([r, g, b].map(c => Math.floor(c * 255)))
}

export const decimalsToHex = (color) => {
  const components = color.map(c => c.toString(16))
  return `#${components.join('')}`
}

export const generateColors = () => {
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
