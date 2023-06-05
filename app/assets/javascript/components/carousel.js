document.addEventListener('DOMContentLoaded', () => {
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
})
