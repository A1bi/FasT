import { Controller } from '@hotwired/stimulus'
import { createSubscription } from 'components/actioncable'
import { colorToRgbCss, generateColors } from 'components/dynamic_colors'
import { toggleDisplay } from 'components/utils'
import moment from 'moment/min/moment-with-locales'

export default class extends Controller {
  static targets = [
    'video', 'admissionIn', 'admissionInTime', 'beginsIn', 'beginsInTime', 'seating', 'clock', 'logo',
    'ticketsSold', 'numberOfSeats', 'checkIns'
  ]

  static values = {
    admissionDate: String,
    beginDate: String
  }

  initialize () {
    moment.locale('de')
    moment.relativeTimeThreshold('ss', 0)

    this.admissionDate = moment(this.admissionDateValue)
    this.beginDate = moment(this.beginDateValue)

    this.subscribeToChannel()
    this.playVideoStream()
    this.updateTimes()
    this.shuffleLogoColors()

    if (this.beginDate.isAfter()) {
      this.toggleBottomBar(true)
    }

    document.addEventListener('keyup', event => {
      if (event.code !== 'Space') return

      if (this.peerConnection) {
        this.peerConnection.close()
        this.peerConnection = null
      } else {
        this.playVideoStream()
      }
    })
  }

  async subscribeToChannel () {
    this.subscription = createSubscription({
      channel: 'BackstageTvChannel'
    }, {
      received: data => {
        if ('tickets_sold' in data) {
          this.updateTicketStats(data)
        } else if ('check_ins' in data) {
          this.updateCheckInsStats(data)
        }
      }
    })
  }

  async playVideoStream () {
    await this.initPeerConnection()
    const ws = new WebSocket('ws://localhost:1984/api/ws?src=cam&media=video')

    ws.addEventListener('open', async () => {
      this.peerConnection.addEventListener('icecandidate', ev => {
        if (!ev.candidate) return
        const msg = {
          type: 'webrtc/candidate',
          value: ev.candidate.candidate
        }
        ws.send(JSON.stringify(msg))
      })

      const offer = await this.peerConnection.createOffer()
      await this.peerConnection.setLocalDescription(offer)
      const msg = {
        type: 'webrtc/offer',
        value: this.peerConnection.localDescription.sdp
      }
      ws.send(JSON.stringify(msg))
    })

    ws.addEventListener('message', ev => {
      const msg = JSON.parse(ev.data)
      if (msg.type === 'webrtc/candidate') {
        this.peerConnection.addIceCandidate({
          candidate: msg.value,
          sdpMid: '0'
        })
      } else if (msg.type === 'webrtc/answer') {
        this.peerConnection.setRemoteDescription({
          type: 'answer',
          sdp: msg.value
        })
      }
    })
  }

  async initPeerConnection () {
    this.peerConnection = new RTCPeerConnection()
    const transceiver = this.peerConnection.addTransceiver('video', { direction: 'recvonly' })
    const videoTrack = transceiver.receiver.track
    this.videoTarget.srcObject = new MediaStream([videoTrack])
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

  updateTicketStats (data) {
    this.ticketsSoldTargets.forEach(target => { target.innerText = data.tickets_sold })
    this.numberOfSeatsTarget.innerText = data.number_of_seats
  }

  updateCheckInsStats (data) {
    this.checkInsTarget.innerText = data.check_ins
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
