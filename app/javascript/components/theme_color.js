const meta = document.createElement('meta')
meta.name = 'theme-color'
document.querySelector('head').appendChild(meta)

const updateThemeColor = () => {
  const header = document.querySelector('header')
  if (!header) return

  const themeColor = window.getComputedStyle(header).backgroundColor
  meta.content = themeColor

  const rulers = document.querySelectorAll('hr')
  if (rulers.length < 1) return

  const bgImage = window.getComputedStyle(rulers[0]).backgroundImage.replace(/black|hsl|rgb\(.+?\)/, themeColor)
  rulers.forEach(el => { el.style.backgroundImage = bgImage })
}

document.addEventListener('DOMContentLoaded', updateThemeColor)

window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', updateThemeColor)
