import { Controller } from 'stimulus'
import { fetch, toggleDisplay } from '../components/utils'

export default class extends Controller {
  static targets = ['photo', 'indexCurrent', 'indexMax', 'text',
    'downloadLink'];

  currentIndex = -1;

  async connect () {
    await this.fetchPhotos()
    this.registerEvents()
    this.goToNext()
  }

  async fetchPhotos () {
    const data = await fetch(this.data.get('photos-path'))
    this.photos = data.photos
  }

  updatePic () {
    const photo = this.photos[this.currentIndex]

    this.photoTarget.setAttribute('src', photo.url.big)

    this.indexCurrentTarget.innerText = this.currentIndex + 1
    this.indexMaxTarget.innerText = this.photos.length

    this.textTarget.innerText = photo.text

    if (photo.url.full) {
      this.downloadLinkTarget.setAttribute('href', photo.url.full)
    }
    toggleDisplay(this.downloadLinkTarget, photo.url.full)
  }

  getIndex (direction) {
    return (this.currentIndex + direction) % this.photos.length
  }

  goTo (direction) {
    this.currentIndex = this.getIndex(direction)
    this.updatePic()
  }

  goToNext () {
    this.goTo(1)
  }

  goToPrevious () {
    this.goTo(-1)
  }

  registerEvents () {
    document.addEventListener('keyup', event => {
      switch (event.which) {
        case 37:
          this.goToPrevious()
          break
        case 39:
          this.goToNext()
          break
      }
    })

    this.photoTarget.addEventListener('load', () => {
      const nextPhoto = this.photos[this.getIndex(1)]
      const preloadImage = new window.Image()
      preloadImage.src = nextPhoto.url.big
    })
  }
}
