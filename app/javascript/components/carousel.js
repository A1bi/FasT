import { toggleDisplay } from 'components/utils'

const SLIDE_DURATION = 6000
const TRANSITION_DURATION = 2000

const showNextItem = () => {
  const nextIndex = (Array.from(photos).indexOf(currentPhoto) + 1) % photos.length
  const nextPhoto = photos[nextIndex]
  if (!getImageTag(nextPhoto).complete) {
    return setTimeout(showNextItem, 1000)
  }

  const sinceLast = (new Date()).getTime() - lastPhotoShownAt.getTime()
  const totalDuration = SLIDE_DURATION + (initialPhoto ? 0 : TRANSITION_DURATION)
  const nextPhotoDelay = Math.max(0, totalDuration - sinceLast)
  initialPhoto = false

  setTimeout(() => {
    lastPhotoShownAt = new Date()

    currentPhoto.addEventListener('transitionend', e => {
      e.currentTarget.classList.remove('out')
      showNextItem()
    }, { once: true })
    currentPhoto.classList.remove('active')
    currentPhoto.classList.add('out')
    currentPhoto = nextPhoto
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
  }, nextPhotoDelay)
}

const loadPhoto = (index) => {
  const photo = photos[index]
  const image = getImageTag(photo)

  toggleDisplay(photo, true)
  image.removeAttribute('loading')

  const nextIndex = index + 1
  if (nextIndex >= photos.length) return

  if (image.complete) {
    loadPhoto(nextIndex)
  } else {
    image.addEventListener('load', () => loadPhoto(nextIndex))
  }
}

const getImageTag = (photo) => {
  return photo.querySelector('img')
}

let photos
let currentPhoto
let activeTitle
let lastPhotoShownAt = new Date()
let initialPhoto = true

document.addEventListener('DOMContentLoaded', () => {
  photos = document.querySelectorAll('.carousel .photo')
  currentPhoto = photos[0]
  activeTitle = document.querySelector('.carousel .title.active')

  if (photos.length <= 1) return

  loadPhoto(0)
  showNextItem()
})
