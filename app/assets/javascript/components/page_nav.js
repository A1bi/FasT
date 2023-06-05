document.addEventListener('DOMContentLoaded', () => {
  const anchorsObserver = new window.IntersectionObserver(entries => {
    entries.forEach(entry => {
      document.querySelector(`.page-nav li:has(a[href='#${entry.target.id}'])`)
        .classList.toggle('active', entry.isIntersecting)
    })
  }, { rootMargin: '-20% 0% -80% 0%' })

  const anchors = document.querySelectorAll('.page-nav-anchor')
  anchors.forEach(anchor => anchorsObserver.observe(anchor))
})
