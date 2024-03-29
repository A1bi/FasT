import { toggleDisplay, fetchRaw } from 'components/utils'
import { captureMessage, addBreadcrumb } from 'components/sentry'

export default class {
  constructor (container, delegate, zoomable) {
    this.container = container
    this.delegate = delegate
    this.zoomable = zoomable !== false
    this.zoomScale = 1
    this.eventId = this.container.dataset.eventId
    this.seats = {}
    this.topBar = this.container.querySelector('.top-bar')
    this.key = this.container.querySelector('.key')

    toggleDisplay(this.topBar, this.zoomable)

    window.addEventListener('resize', () => {
      this.originalHeight = null
      this.unzoom()
      this.updateSvgHeight()
    })
  }

  async init () {
    this.plan = this.container.querySelector('.plan')

    try {
      const svgContent = await fetchRaw(this.container.dataset.planPath)
      this.plan.querySelector('.canvas').innerHTML = svgContent
    } catch (error) {
      captureMessage('Failed to load seating SVG', {
        extra: { error }
      })
      return
    }

    this.svg = this.container.querySelector('svg')
    this.svg.setAttribute('preserveAspectRatio', 'xMinYMin')

    if (this.zoomable && this.svg.querySelector('.block')) {
      const content = this.svg.querySelectorAll(
        ':scope > g, :scope > rect, :scope > line, :scope > path, :scope > text'
      )
      this.globalGroup = this.createSvgElement('g')
      this.globalGroup.classList.add('global')
      this.svg.appendChild(this.globalGroup)
      this.svg.classList.add('zoomable')
      content.forEach(c => this.globalGroup.appendChild(c))

      this.globalGroup.addEventListener('transitionend', event => {
        if (event.propertyName === 'transform') {
          this.toggleClassesAfterZoom()
        }
      })

      this.svg.querySelectorAll(':scope .shield').forEach(shield => {
        shield.addEventListener('click', () => this.clickedShield(shield))
      })

      this.container.querySelector('.unzoom').addEventListener('click', () => this.unzoom())
      this.unzoom()
    }

    this.svg.querySelectorAll(':scope .seat').forEach(seat => {
      let text = ''
      if (seat.dataset.row) {
        text += `Reihe ${seat.dataset.row} – `
      }
      text += `Sitz ${seat.dataset.number}`
      const title = this.createSvgElement('title')
      title.textContent = text
      seat.querySelector('text').append(title)
      this.seats[seat.dataset.id] = seat

      seat.addEventListener('click', event => {
        if (this.clickedSeat) this.clickedSeat(event.currentTarget)
      })
    })

    if (this.key) {
      this.key.querySelectorAll(':scope [data-status]').forEach(box => {
        const status = box.dataset.status

        // if the status class is present, this key has already been
        // created before (e.g. after a reinit of the seating)
        // so in this case don't create it again
        if (status && !box.matches(`.status-${status}`)) {
          box.classList.add(`status-${status}`)

          const iconBox = box.querySelector('.icon')
          const icon = this.createSvgElement('svg')
          const seat = this.svg.querySelector(`#seat-${status} > *`)
          if (seat) {
            const width = seat.getAttribute('width')
            const height = seat.getAttribute('height')
            icon.setAttribute('viewBox', `0 0 ${width} ${height}`)
            icon.appendChild(seat.cloneNode())
            iconBox.append(icon)
          } else {
            toggleDisplay(box, false)
          }
        }
      })

      this.toggleExclusiveSeatsKey(false)
    }
  }

  clickedShield (shield) {
    if (this.plan.matches('.zoomed')) return

    const block = shield.closest('.block')
    block.parentNode.querySelectorAll(':scope .block').forEach(b => {
      if (b !== block) b.classList.add('disabled')
    })

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
          const coords = match.split(' ')
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

    const viewBox = this.svg.viewBox.baseVal
    const offsetX = viewBox.x + globalBBox.width / 2 - (x + shieldBBox.width / 2) * scale
    const offsetY = viewBox.y + globalBBox.height * heightExtension / 2 - (y + shieldBBox.height / 2) * scale

    this.zoom(scale, offsetX, offsetY, shield)
  }

  zoom (scale, translateX, translateY, shield) {
    this.zoomScale = scale
    this.zoomedShield = shield

    const zoomed = scale !== 1
    let blockName = 'Übersicht'

    if (zoomed) {
      blockName = this.zoomedShield.querySelector('text').innerHTML

      this.addBreadcrumb('zoomed to block', {
        name: blockName
      })
    } else {
      this.svg.classList.remove('numbers', 'zoomed-in')
      this.svg.querySelectorAll(':scope .block').forEach(b => b.classList.remove('disabled'))

      if (this.plan.matches('.zoomed')) {
        this.addBreadcrumb('returned to overview')
      }
    }

    this.plan.classList.toggle('zoomed', zoomed)
    this.updateSvgHeight()
    this.globalGroup.style.transform = `translate(${translateX}px, ${translateY}px) scale(${scale})`
    this.topBar.querySelector('.block-name').textContent = blockName
  }

  unzoom () {
    this.zoomScale = 1
    this.zoom(1, 0, 0)
  }

  updateSvgHeight () {
    let height = 'auto'
    if (this.zoomScale !== 1) {
      this.originalHeight = this.originalHeight || this.svg.getBoundingClientRect().height
      height = Math.max(this.originalHeight, this.zoomedShield.getBoundingClientRect().height * this.zoomScale)
    }
    this.svg.style.height = height
  }

  toggleClassesAfterZoom () {
    ['numbers', 'zoomed-in'].forEach(c => this.svg.classList.toggle(c, this.plan.matches('.zoomed')))
  }

  setStatusForSeat (seat, status) {
    seat.classList.remove(`status-${seat.dataset.status}`)
    seat.classList.add('status-' + status)
    seat.querySelector('use').setAttribute('xlink:href', `#seat-${status}`)
    seat.dataset.status = status
  }

  toggleExclusiveSeatsKey (toggle) {
    if (!this.key) return

    toggleDisplay(this.key.querySelector('.status-exclusive'), toggle)
  }

  createSvgElement (tagName) {
    const namespace = 'http://www.w3.org/2000/svg'
    return document.createElementNS(namespace, tagName)
  }

  addBreadcrumb (message, data, level) {
    addBreadcrumb({
      category: 'seating',
      message,
      data,
      level
    })
  }
}
