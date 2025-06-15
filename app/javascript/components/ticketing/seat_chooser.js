import io from 'socket.io-client'
import Seating from 'components/ticketing/seating'
import { slideToggle, togglePluralText } from 'components/utils'

export default class extends Seating {
  constructor (container, delegate, zoomable, privileged) {
    super(container, delegate, zoomable)

    this.errorBox = this.container.querySelector('.error')
    this.noErrors = false
    this.privileged = privileged
  }

  async init () {
    await super.init()

    this.date = null
    this.seatsInfo = {}
    this.numberOfSeats = 0
    this.socketId = null

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
    const id = parseInt(seat.dataset.id)
    const originalStatus = seat.dataset.status
    const allowedStatuses = ['available', 'exclusive', 'chosen']
    if (allowedStatuses.indexOf(originalStatus) === -1) return

    const newStatus = (originalStatus === 'chosen') ? 'available' : 'chosen'
    this.setStatusForSeat(seat, newStatus)

    this.node.emit('chooseSeat', { seatId: id }, res => {
      if (!res.ok) this.setStatusForSeat(seat, originalStatus)
      this.updateErrorBox()

      this.addBreadcrumb('chose seat', {
        id,
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
    this.updateErrorBox()

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

    if (this.showErrorBox) {
      if (toggle) {
        togglePluralText(this.errorBox, number)
      }
      this.toggleErrorBox(toggle)
    }

    return !toggle
  }

  toggleErrorBox (toggle) {
    slideToggle(this.errorBox, toggle)
  }

  getSeatsYetToChoose () {
    return this.numberOfSeats - this.svg.querySelectorAll(':scope .seat.status-chosen').length
  }

  validate () {
    this.showErrorBox = true
    const validated = this.updateErrorBox()
    if (!validated) {
      // scrollIntoView does not work, it scrolls only the parent container because of the height constraint
      const top = this.errorBox.getBoundingClientRect().top + window.scrollY - 100
      window.scrollTo({ top, behavior: 'smooth' })
    }
    return validated
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

    this.node.on('connect_error', error => {
      if (!this.socketId) {
        this.connectionFailed()
        this.delegate.seatChooserCouldNotConnect()
      } else if (error.type !== 'TransportError') {
        this.connectionFailed()
        this.delegate.seatChooserCouldNotReconnect()
      }
    })

    this.node.io.on('reconnect_attempt', () => {
      this.delegate.seatChooserIsReconnecting()
    })

    this.node.io.on('reconnect_failed', () => {
      this.connectionFailed()
      this.delegate.seatChooserDisconnected()
    })

    this.node.on('updateSeats', res => {
      console.log('Seat updates received')
      this.updateSeats(res.seats)
    })

    this.node.on('expired', () => {
      this.delegate.seatChooserExpired()
    })

    const events = ['connect', 'connect_error', 'reconnecting', 'reconnect_failed', 'error']
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
