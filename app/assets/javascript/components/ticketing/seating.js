import $ from 'jquery'
import { captureMessage, addBreadcrumb } from '@sentry/browser'
import { isIE } from '../utils'

export default class {
  constructor (container, delegate, zoomable) {
    this.container = $(container)
    this.delegate = delegate
    this.zoomable = zoomable !== false
    this.eventId = this.container.data('event-id')
    this.seats = {}
    this.key = this.container.find('.key > div')
  }

  init () {
    return new Promise(resolve => {
      this.plan = this.container.find('.plan')

      this.container.find('.unsupported-browser').toggle(isIE())

      this.plan.find('.canvas').load(this.container.data('plan-path'), (response, _status, xhr) => {
        this.svg = this.container.find('svg')

        if (!response || !this.svg.length) {
          captureMessage('Failed to load seating SVG', {
            extra: {
              xhr_response: response,
              xhr_status: xhr.status,
              xhr_status_text: xhr.statusText
            }
          })
          return
        }

        this.svg[0].setAttribute('preserveAspectRatio', 'xMinYMin')

        if (this.zoomable && this.svg.find('.block').length > 1) {
          const content = this.svg.find('> g, > rect, > line, > path, > text')
          this.globalGroup = this.createSvgElement('g')
          if (this.globalGroup.classList) {
            this.globalGroup.classList.add('global')
          // IE workaround
          } else {
            this.globalGroup.className += ' global'
          }
          this.svg[0].appendChild(this.globalGroup)

          for (let i = 0; i < content.length; i++) {
            this.globalGroup.appendChild(content[i])
          }

          this.globalGroup.addEventListener('transitionend', event => {
            if (event.propertyName === 'transform') {
              this.toggleClassesAfterZoom()
            }
          })

          this.svg.addClass('zoomable')

          this.svg.find('.shield').click(event => {
            this.clickedShield(event.currentTarget)
          })

          this.container.find('.unzoom').click(() => this.unzoom())
          this.unzoom()
        }

        this.allSeats = this.svg.find('.seat')
          .each((_i, seat) => {
            const $seat = $(seat)
            let text = ''
            if ($seat.data('row')) {
              text += `Reihe ${$seat.data('row')} – `
            }
            text += `Sitz ${$seat.data('number')}`
            const title = this.createSvgElement('title')
            title.innerHTML = text
            $seat.find('text').append(title)
            this.seats[$seat.data('id')] = $seat
          })
          .click(event => {
            if (this.clickedSeat) this.clickedSeat($(event.currentTarget))
          })

        if (this.key.length) {
          for (const box of this.key.find('div')) {
            const $this = $(box)
            const status = $this.data('status')

            // if the status class is present, this key has already been
            // created before (e.g. after a reinit of the seating)
            // so in this case don't create it again
            if (status && !$this.is(`.status-${status}`)) {
              $this.addClass(`status-${status}`)

              if ($this.is('.icon')) {
                const icon = this.createSvgElement('svg')
                const seat = this.svg.find(`#seat-${status} > *`)[0]
                // if (status === 'available') continue
                if (seat) {
                  const width = seat.getAttribute('width')
                  const height = seat.getAttribute('height')
                  icon.setAttribute('viewBox', `0 0 ${width} ${height}`)
                  icon.appendChild(seat.cloneNode())
                  $this.append(icon)
                } else {
                  $this.hide()
                }
              }
            }
          }

          this.toggleExclusiveSeatsKey(false)
        }

        resolve()
      })
    })
  }

  clickedShield (shield) {
    if (this.plan.is('.zoomed')) return

    $(shield).parent('.block').siblings('.block').addClass('disabled')

    const shieldBox = shield.getBoundingClientRect()
    const shieldBBox = shield.getBBox()
    const globalBox = this.globalGroup.getBoundingClientRect()
    const globalBBox = this.globalGroup.getBBox()

    let currentNode = shield.querySelector('rect, path')

    let x = parseFloat(currentNode.getAttribute('x')) || 0
    let y = parseFloat(currentNode.getAttribute('y')) || 0

    // calculate offset of the element by summing up the offsets of parent nodes
    while (currentNode.tagName !== 'svg') {
      const transform = currentNode.getAttribute('transform')
      if (transform) {
        const matrix = currentNode.transform.baseVal.consolidate().matrix
        x += matrix.e
        y += matrix.f
      }

      // calculate minimum X and Y values for path to get the offset
      if (currentNode.tagName === 'path') {
        const path = currentNode.getAttribute('d')
        const matches = path.match(/([\d.-]+) ([\d.-]+)/g)
        const xx = []
        const yy = []
        matches.forEach(function (match) {
          var coords = match.split(' ')
          xx.push(parseFloat(coords[0]))
          yy.push(parseFloat(coords[1]))
        })
        x += Math.min.apply(null, xx)
        y += Math.min.apply(null, yy)
      }
      currentNode = currentNode.parentNode
    }

    let heightExtension = 1.5
    let scale = globalBox.width / shieldBox.width
    const scaledHeight = shieldBox.height * scale
    if (scaledHeight > globalBox.height * heightExtension) {
      scale = globalBox.height * heightExtension / shieldBox.height
    } else {
      heightExtension = Math.max(1, scaledHeight / globalBox.height)
    }

    const viewBox = this.svg[0].viewBox.baseVal
    const offsetX = viewBox.x + globalBBox.width / 2 - (x + shieldBBox.width / 2) * scale
    const offsetY = viewBox.y + globalBBox.height * heightExtension / 2 - (y + shieldBBox.height / 2) * scale

    this.zoom(scale, offsetX, offsetY, shield)
  }

  zoom (scale, translateX, translateY, shield) {
    const zoom = scale !== 1
    let height = this.originalHeight
    const topBar = this.container.find('.top-bar')
    let blockName = 'Übersicht'

    if (zoom) {
      this.originalHeight = this.originalHeight || this.svg.height()
      height = Math.max(this.originalHeight, shield.getBoundingClientRect().height * scale)
      blockName = shield.querySelector('text').innerHTML

      this.addBreadcrumb('zoomed to block', {
        name: blockName
      })
    } else {
      this.svg.removeClass('numbers zoomed-in').find('.block').removeClass('disabled')

      if (this.plan.is('.zoomed')) {
        this.addBreadcrumb('returned to overview')
      }
    }

    this.plan.toggleClass('zoomed', zoom)
    this.svg.height(height)
    this.globalGroup.style.transform = `translate(${translateX}px, ${translateY}px) scale(${scale})`
    topBar.find('.block-name').text(blockName)

    if (this.delegate && typeof (this.delegate.resizeDelegateBox) === 'function') {
      this.delegate.resizeDelegateBox(false)
    }
  }

  unzoom () {
    this.zoom(1, 0, 0)
  }

  toggleClassesAfterZoom () {
    this.svg.toggleClass('numbers zoomed-in', this.plan.is('.zoomed'))
  }

  setStatusForSeat (seat, status) {
    seat.removeClass(`status-${seat.data('status')}`)
    seat.addClass('status-' + status)
    seat.find('use').attr('xlink:href', `#seat-${status}`)
    seat.data('status', status)
  }

  toggleExclusiveSeatsKey (toggle) {
    if (this.key.length < 1) return

    this.key.find('.status-exclusive').toggle(toggle)
  }

  createSvgElement (tagName) {
    const namespace = 'http://www.w3.org/2000/svg'
    return document.createElementNS(namespace, tagName)
  }

  addBreadcrumb (message, data, level) {
    addBreadcrumb({
      category: 'seating',
      message: message,
      data: data,
      level: level
    })
  }
}
