const updateRulerColor = () => {
  const rulers = document.querySelectorAll('hr')
  if (rulers.length < 1) return

  const bgColor = window.getComputedStyle(document.querySelector('header')).backgroundColor
  const bgImage = window.getComputedStyle(rulers[0]).backgroundImage.replace(/black|hsl|rgb\(.+?\)/, bgColor)
  document.querySelectorAll('hr').forEach(el => { el.style.backgroundImage = bgImage })
}

document.addEventListener('DOMContentLoaded', updateRulerColor)

window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', updateRulerColor)
