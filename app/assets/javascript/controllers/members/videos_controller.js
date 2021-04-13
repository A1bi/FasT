import { Controller } from 'stimulus'
import { fetch, toggleDisplay } from '../../components/utils'

import '../../styles/members/videos_controller.sass'

export default class extends Controller {
  static targets = ['videoList', 'player', 'chapterMarks', 'audioLink']

  async connect () {
    await this.fetchVideoInformation()
    this.setUpVideoList()
    this.registerEvents()
    this.setCurrentVideo(0)
  }

  registerEvents () {
    this.playerTarget.addEventListener('timeupdate', () => this.updateCurrentChapterMark())
  }

  async fetchVideoInformation () {
    const data = await fetch('/uploads/members/videos.json')
    this.videos = data.videos
  }

  setUpVideoList () {
    this.setUpList(this.videoListTarget, this.videos, (link, video, i) => {
      link.innerText = video.title
      link.dataset.videoIndex = i
    })
  }

  setCurrentVideo (event) {
    const index = event ? event.currentTarget.dataset.videoIndex : 0
    const video = this.videos[index]
    if (!video || video === this.currentVideo) return

    this.currentVideo = video
    this.playerTarget.src = `${this.currentVideo.videoSrc}#t=0.1`
    this.setUpChapterMarks()
    this.setUpAudioLink()
  }

  setUpChapterMarks () {
    this.setUpList(this.chapterMarksTarget, this.currentVideo.chapterMarks, (link, mark, i) => {
      link.innerText = `${mark.title} (${mark.timecode})`
      link.dataset.chapterIndex = i

      mark.seconds = this.secondsFromTimecode(mark.timecode)
    })
  }

  updateCurrentChapterMark () {
    this.chapterMarksTarget.querySelectorAll('li.current')
      .forEach(el => el.classList.remove('current'))
    const entries = this.chapterMarksTarget.querySelectorAll('li')

    for (var i = this.currentVideo.chapterMarks.length - 1; i >= 0; i--) {
      const mark = this.currentVideo.chapterMarks[i]
      if (this.playerTarget.currentTime >= mark.seconds) {
        entries[i].classList.add('current')
        break
      }
    }
  }

  jumpToChapterMark (event) {
    if (!this.playerTarget.paused) {
      this.playerTarget.pause()
      this.playerTarget.addEventListener('seeked', () => {
        this.playerTarget.play()
      }, { once: true })
    }

    const index = event.currentTarget.dataset.chapterIndex
    const mark = this.currentVideo.chapterMarks[index]
    this.playerTarget.currentTime = mark.seconds
  }

  setUpAudioLink () {
    toggleDisplay(this.audioLinkTarget, this.currentVideo.audioSrc)
    this.audioLinkTarget.querySelector('a').setAttribute('href', this.currentVideo.audioSrc)
  }

  setUpList (target, items, callback) {
    const show = items.length > 1
    toggleDisplay(target, show)
    if (!show) return

    const list = target.querySelector('ul')
    const template = list.querySelector('li')
    list.innerHTML = ''

    items.forEach((item, i) => {
      const entry = template.cloneNode(true)
      const link = entry.querySelector('a')
      callback(link, item, i)
      list.appendChild(entry)
    })
  }

  secondsFromTimecode (timecode) {
    const match = timecode.match(/(\d{2}):(\d{2}):(\d{2})/)
    return (parseInt(match[1]) * 60 + parseInt(match[2])) * 60 + parseInt(match[3])
  }
}
