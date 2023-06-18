document.addEventListener('DOMContentLoaded', () => {
  const anchorsObserver = new window.IntersectionObserver(entries => {
    entries.forEach(entry => {
      const link = document.querySelector(`.page-nav a[href='#${entry.target.id}']`)
      if (!link) return

      link.closest('li').classList.toggle('active', entry.isIntersecting)
    })
  }, { rootMargin: '-20% 0% -80% 0%' })

  const anchors = document.querySelectorAll('.page-nav-anchor')
  anchors.forEach(anchor => anchorsObserver.observe(anchor))
})
