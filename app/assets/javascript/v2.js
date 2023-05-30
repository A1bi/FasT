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
      colors[i] = [huelogo, 70, 60]
    }

    prevHues[i] = huelogo
    prevColors[i] = colors[i]
  }

  colors.unshift([huebg, 40, 90])

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

  document.querySelector('.menu-toggle').addEventListener('click', () => toggleMenu())

  window.addEventListener('click', e => {
    // close on same page + same hash
    if (e.target.href !== window.location.href && (
      e.target.matches('.menu-toggle') || document.querySelector('nav').contains(e.target))
    ) return

    toggleMenu(false)
  })

  document.addEventListener('keydown', e => {
    if (e.key === 'Escape') toggleMenu(false)
  })

  window.addEventListener('hashchange', () => toggleMenu(false))

  const carouselTitles = document.querySelectorAll('.carousel .title')
  const carouselPhotos = document.querySelectorAll('.carousel .photo')
  var currentTitle = document.querySelector('.carousel .title.active')
  var currentPhoto = document.querySelector('.carousel .photo.active')

  const showNextCarouselItem = () => {
    setTimeout(() => {
      const nextIndex = (Array.from(carouselTitles).indexOf(currentTitle) + 1) % carouselTitles.length
      const nextTitle = carouselTitles[nextIndex]

      currentTitle.addEventListener('transitionend', () => {
        currentTitle = nextTitle
        currentTitle.addEventListener('transitionend', showNextCarouselItem, { once: true })
        currentTitle.classList.add('active')
      }, { once: true })
      currentTitle.classList.remove('active')

      currentPhoto.addEventListener('transitionend', e => e.currentTarget.classList.remove('out'), { once: true })
      currentPhoto.classList.remove('active')
      currentPhoto.classList.add('out')
      currentPhoto = carouselPhotos[nextIndex]
      currentPhoto.classList.add('active')
    }, 5000)
  }

  if (carouselTitles.length > 1) showNextCarouselItem()

  const root = document.querySelector(':root')
  const helper = document.querySelector('.sticky-helper')
  const observer = new window.IntersectionObserver(([el]) => {
    root.classList.toggle('top-bar-stuck', !el.isIntersecting)
  })
  observer.observe(helper)

  const anchorsObserver = new window.IntersectionObserver(entries => {
    entries.forEach(entry => {
      document.querySelector(`.page-nav li:has(a[href='#${entry.target.id}'])`)
        .classList.toggle('active', entry.isIntersecting)
    })
  }, { rootMargin: '-20% 0% -80% 0%' })

  const anchors = document.querySelectorAll('.page-nav-anchor')
  anchors.forEach(anchor => anchorsObserver.observe(anchor))

  document.querySelectorAll('[data-controller="content-reveal"]').forEach(el => {
    const contentTarget = el.querySelector('[data-target="content-reveal.content"')

    el.querySelector('[data-action="content-reveal#reveal"]').addEventListener('click', () => {
      el.classList.toggle('revealed')

      const maxHeight = contentTarget.scrollHeight
      const style = contentTarget.style
      style.maxHeight = `${!parseInt(style.maxHeight) ? maxHeight : 0}px`
    })
  })
})
