import io from 'socket.io-client'
import Seating from './seating'
import { togglePluralText } from '../utils'

export default class extends Seating {
  constructor (container, delegate, zoomable, privileged) {
    super(container, delegate, zoomable)

    this.date = null
    this.seatsInfo = {}
    this.numberOfSeats = 0
    this.node = null
    this.socketId = null
    this.errorBox = this.container.find('.error')
    this.noErrors = false
    this.privileged = privileged
  }

  async init () {
    await super.init()

    this.node = io('/seating', {
      path: '/node',
      reconnectionAttempts: this.privileged ? null : 6,
      query: {
        event_id: this.eventId,
        privileged: !!this.privileged
      }
    })

    this.registerEvents()
  }

  updateSeats (seats) {
    const updatedSeats = {}
    for (const dateId in seats) {
      this.seatsInfo[dateId] = this.seatsInfo[dateId] || {}
      updatedSeats[dateId] = updatedSeats[dateId] || {}

      for (const seatId in seats[dateId]) {
        const seat = updatedSeats[dateId][seatId] =
          this.seatsInfo[dateId][seatId] = this.seatsInfo[dateId][seatId] || {}
        const seatInfo = seats[dateId][seatId]
        seat.taken = !!seatInfo.t
        seat.chosen = !!seatInfo.c
        seat.exclusive = !!seatInfo.e
      }
    }
    this.updateSeatPlan(updatedSeats)
  }

  updateSeatPlan (updatedSeats = this.seatsInfo) {
    if (!this.date) return

    console.log('Updating seating plan')
    updatedSeats = updatedSeats[this.date]
    if (!updatedSeats) return

    for (const seatId in updatedSeats) {
      const seat = this.seats[seatId]
      if (!seat) continue

      const seatInfo = updatedSeats[seatId]
      let status = 'chosen'
      if (!seatInfo.chosen) {
        if (seatInfo.taken && !seatInfo.chosen) {
          status = 'taken'
        } else if (seatInfo.exclusive) {
          status = 'exclusive'
        } else if (!seatInfo.taken && !seatInfo.chosen) {
          status = 'available'
        }
      }
      this.setStatusForSeat(seat, status)
    }

    const seats = Object.values(this.seatsInfo[this.date])
    const exclusiveSeats = seats.some(seat => seat.exclusive)
    this.toggleExclusiveSeatsKey(exclusiveSeats)
  }

  chooseSeat (seat) {
    const id = seat.data('id')
    const originalStatus = seat.data('status')
    const allowedStatuses = ['available', 'exclusive', 'chosen']
    if (allowedStatuses.indexOf(originalStatus) === -1) return

    const newStatus = (originalStatus === 'chosen') ? 'available' : 'chosen'
    this.setStatusForSeat(seat, newStatus)

    this.node.emit('chooseSeat', { seatId: id }, res => {
      if (!res.ok) this.setStatusForSeat(seat, originalStatus)
      this.updateErrorBoxIfVisible()

      this.addBreadcrumb('chose seat', {
        id: id,
        previous_status: originalStatus,
        new_status: newStatus,
        success: res.ok ? 'true' : 'false'
      })
    })
  }

  setDateAndNumberOfSeats (date, number, callback) {
    this.numberOfSeats = number
    if (this.date !== date) {
      this.date = date
      this.updateSeatPlan()
    }
    this.updateErrorBoxIfVisible()

    this.node.emit('setDateAndNumberOfSeats', {
      date: this.date,
      numberOfSeats: this.numberOfSeats
    }, callback)
  }

  reset () {
    this.node.emit('reset')
  }

  updateErrorBox () {
    const number = this.getSeatsYetToChoose()
    const toggle = number > 0

    if (toggle) {
      togglePluralText(this.errorBox, number)
    }

    this.toggleErrorBox(toggle)
  }

  updateErrorBoxIfVisible () {
    if (this.errorBox.is(':visible')) this.updateErrorBox()
  }

  toggleErrorBox (toggle) {
    if (!toggle && !this.errorBox.is(':visible')) {
      this.errorBox.hide()
      return
    }
    if (typeof (this.delegate.slideToggle) === 'function') {
      this.delegate.slideToggle(this.errorBox, toggle)
    } else {
      this.errorBox[`slide${toggle ? 'Down' : 'Up'}`](this.errorBox)
    }
  }

  getSeatsYetToChoose () {
    return this.numberOfSeats - this.allSeats.filter('.status-chosen').length
  }

  validate () {
    this.updateErrorBox()
    return this.getSeatsYetToChoose() < 1
  }

  clickedSeat (seat) {
    if (seat) this.chooseSeat(seat)
  }

  disconnect () {
    this.node.disconnect()
  }

  connectionFailed () {
    this.node.io.skipReconnect = true
  }

  registerEvents () {
    window.addEventListener('beforeunload', () => { this.noErrors = true })

    this.node.on('connect', () => {
      if (!this.socketId) {
        this.socketId = this.node.id

        this.node.io.opts.query = {
          restore_id: this.socketId
        }
      }
      this.delegate.seatChooserIsReady()
    })

    this.node.on('connect_error', () => {
      if (this.socketId) return
      this.connectionFailed()
      this.delegate.seatChooserCouldNotConnect()
    })

    this.node.on('reconnecting', () => {
      this.delegate.seatChooserIsReconnecting()
    })

    this.node.on('reconnect_failed', () => {
      this.connectionFailed()
      this.delegate.seatChooserDisconnected()
    })

    this.node.on('updateSeats', res => {
      console.log('Seat updates received')
      this.updateSeats(res.seats)
    })

    this.node.on('error', error => {
      if (error instanceof Object) return

      this.connectionFailed()
      if (this.socketId) {
        this.delegate.seatChooserCouldNotReconnect()
      } else {
        this.delegate.seatChooserCouldNotConnect()
      }
    })

    this.node.on('expired', () => {
      this.delegate.seatChooserExpired()
    })

    const events = ['connect', 'connect_error', 'reconnecting',
      'reconnect_failed', 'error']
    for (const name of events) {
      this.node.on(name, () => {
        const isError = name.indexOf('error') > -1 || name.indexOf('fail') > -1
        const eventType = isError ? 'error' : 'info'
        this.addBreadcrumb('node connection event', {
          event: name
        }, eventType)
      })
    }
  }
}
