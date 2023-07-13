const toggleMenu = (toggle) => {
  document.body.classList.toggle('menu-active', toggle)
  const active = document.body.classList.contains('menu-active')
  const height = active ? document.querySelector('nav ul').offsetHeight : 0
  document.querySelector('nav').style.height = `${height}px`
}

document.addEventListener('DOMContentLoaded', () => {
  const menuToggle = document.querySelector('.menu-toggle')
  if (!menuToggle) return

  menuToggle.addEventListener('click', () => toggleMenu())

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

  const root = document.querySelector(':root')
  const helper = document.querySelector('.sticky-helper')
  const observer = new window.IntersectionObserver(([el]) => {
    root.classList.toggle('top-bar-stuck', !el.isIntersecting)
  })
  observer.observe(helper)
})
