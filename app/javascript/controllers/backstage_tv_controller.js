import { Controller } from '@hotwired/stimulus'
import { colorToRgbCss, generateColors } from 'components/dynamic_colors'
import { toggleDisplay } from 'components/utils'
import moment from 'moment/min/moment-with-locales'

const PeerConnection = async (videoElement) => {
  const pc = new RTCPeerConnection()
  const transceiver = pc.addTransceiver('video', { direction: 'recvonly' })
  const videoTrack = transceiver.receiver.track
  videoElement.srcObject = new MediaStream([videoTrack])
  return pc
}

export default class extends Controller {
  static targets = ['video', 'admissionIn', 'admissionInTime', 'beginsIn', 'beginsInTime', 'seating', 'clock', 'logo']
  static values = {
    admissionDate: String,
    beginDate: String
  }

  initialize () {
    moment.locale('de')
    moment.relativeTimeThreshold('ss', 0)

    this.admissionDate = moment(this.admissionDateValue)
    this.beginDate = moment(this.beginDateValue)

    this.playVideoStream()
    this.updateTimes()
    this.shuffleLogoColors()

    if (this.beginDate.isAfter()) {
      this.toggleBottomBar(true)
    }
  }

  async playVideoStream () {
    const pc = await PeerConnection(this.videoTarget)
    const ws = new WebSocket('ws://localhost:1984/api/ws?src=cam&media=video')

    ws.addEventListener('open', async () => {
      pc.addEventListener('icecandidate', ev => {
        if (!ev.candidate) return
        const msg = {
          type: 'webrtc/candidate',
          value: ev.candidate.candidate
        }
        ws.send(JSON.stringify(msg))
      })

      const offer = await pc.createOffer()
      await pc.setLocalDescription(offer)
      const msg = {
        type: 'webrtc/offer',
        value: pc.localDescription.sdp
      }
      ws.send(JSON.stringify(msg))
    })

    ws.addEventListener('message', ev => {
      const msg = JSON.parse(ev.data)
      if (msg.type === 'webrtc/candidate') {
        pc.addIceCandidate({
          candidate: msg.value,
          sdpMid: '0'
        })
      } else if (msg.type === 'webrtc/answer') {
        pc.setRemoteDescription({
          type: 'answer',
          sdp: msg.value
        })
      }
    })
  }

  updateTimes () {
    const current = new Date()
    this.clockTarget.innerText = current.toLocaleTimeString('de-DE')

    toggleDisplay(this.admissionInTarget, this.admissionDate.isAfter())
    toggleDisplay(this.beginsInTarget, this.admissionDate.isBefore())

    if (this.beginDate.isBefore()) {
      this.beginsInTimeTarget.innerText = 'jetzt'
      setTimeout(() => this.toggleBottomBar(false), 10000)
    } else if (this.admissionDate.isBefore()) {
      this.beginsInTimeTarget.innerText = this.beginDate.fromNow()
    } else {
      this.admissionInTimeTarget.innerText = this.admissionDate.fromNow()
    }

    setTimeout(() => this.updateTimes(), 1000)
  }

  toggleBottomBar (toggle) {
    this.element.classList.toggle('bottom-bar-visible', toggle)
  }

  shuffleLogoColors () {
    const colors = generateColors().slice(1)
    this.colors = colors.map(color => colorToRgbCss(color))

    this.updateLogo()
    setTimeout(() => this.shuffleLogoColors(), 60000)
  }

  updateLogo () {
    const logo = this.logoTarget.querySelector('svg')
    logo.querySelectorAll(':scope > g').forEach((group, i) => {
      group.style.fill = this.colors[i % this.colors.length]
    })
  }

  toggleFullscreen () {
    if (document.fullscreen) {
      document.exitFullscreen()
    } else {
      this.element.requestFullscreen()
    }
  }
}
