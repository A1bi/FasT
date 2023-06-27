const showNextCarouselItem = () => {
  setTimeout(() => {
    const nextIndex = (Array.from(carouselPhotos).indexOf(currentPhoto) + 1) % carouselPhotos.length

    currentPhoto.addEventListener('transitionend', e => {
      e.currentTarget.classList.remove('out')
      showNextCarouselItem()
    }, { once: true })
    currentPhoto.classList.remove('active')
    currentPhoto.classList.add('out')
    currentPhoto = carouselPhotos[nextIndex]
    currentPhoto.classList.add('active')

    const nextActiveTitle = document.querySelector(
      `.carousel .title[data-event-identifier="${currentPhoto.dataset.eventIdentifier}"]`
    )
    if (activeTitle === nextActiveTitle) return

    activeTitle.addEventListener('transitionend', () => {
      nextActiveTitle.classList.add('active')
      activeTitle = nextActiveTitle
    }, { once: true })
    activeTitle.classList.remove('active')
  }, 5000)
}

let carouselPhotos
let currentPhoto
let activeTitle

document.addEventListener('DOMContentLoaded', () => {
  carouselPhotos = document.querySelectorAll('.carousel .photo')
  currentPhoto = carouselPhotos[0]
  activeTitle = document.querySelector('.carousel .title.active')

  if (carouselPhotos.length > 1) showNextCarouselItem()
})
