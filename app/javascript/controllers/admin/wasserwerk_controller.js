import { Controller } from '@hotwired/stimulus'
import { toggleDisplay, fetch } from 'components/utils'

export default class extends Controller {
  static targets = [
    'furnaceLevelLabel', 'furnaceOffLabel', 'furnaceScaleStep', 'furnaceForm', 'furnaceLevelInput', 'spinner',
    'temperature', 'humidity', 'updatedAt'
  ]

  static values = {
    stateUrl: String,
    onPrompt: String,
    offPrompt: String,
    errorFetchMessage: String,
    errorSetMessage: String,
    locations: Array
  }

  async connect () {
    this.dayjs = (await import('dayjs')).default
    const relativeTime = (await import('dayjs-plugin-relative-time')).default
    this.dayjs.extend(relativeTime)
    const localeDe = (await import('dayjs-locale-de')).default
    this.dayjs.locale(localeDe)

    this.spinnerVisible = true

    try {
      await this.fetchState()
      window.setInterval(() => this.fetchState(), 30000)
      this.spinnerVisible = false
    } catch (error) {
      window.alert(this.errorFetchMessageValue)
      throw error
    }
  }

  async fetchState () {
    const state = await fetch(this.stateUrlValue, 'get', null, 'no-store')
    if (!state) return

    this.furnaceLevel = state.furnace.level

    this.updateFurnaceState()
    this.updateMeasurements(state)
  }

  updateFurnaceState (state) {
    toggleDisplay(this.furnaceLevelLabelTarget, this.furnaceLevel > 0)
    toggleDisplay(this.furnaceOffLabelTarget, this.furnaceLevel === 0)

    if (this.furnaceLevel > 0) {
      this.furnaceLevelLabelTarget.querySelector('strong span').innerText = this.furnaceLevel
    }

    this.furnaceScaleStepTargets.forEach((step, i) => {
      step.classList.toggle('active', (5 - i) <= this.furnaceLevel)
    })

    if (this.hasFurnaceLevelInputTarget) this.furnaceLevelInputTarget.value = this.furnaceLevel
  }

  async updateMeasurements (state) {
    this.locationsValue.forEach((location, i) => {
      const locationState = state.measurements[location]
      if (!locationState) return

      this.temperatureTargets[i].innerText = locationState.temperature.toLocaleString()
      this.humidityTargets[i].innerText = Math.round(locationState.humidity)
      const updatedAt = this.dayjs(locationState.updated_at)
      this.updatedAtTargets[i].innerText = updatedAt.fromNow()
      this.updatedAtTargets[i].title = updatedAt.toDate().toLocaleString()
    })
  }

  async setFurnaceLevel (event) {
    event.preventDefault()
    this.spinnerVisible = true

    const newLevel = parseInt(this.furnaceLevelInputTarget.value)
    if ((this.furnaceLevel === newLevel) ||
        (this.furnaceLevel === 0 && !window.confirm(this.onPromptValue)) ||
        (newLevel === 0 && !window.confirm(this.offPromptValue))) {
      this.updateFurnaceState()
    } else {
      try {
        await fetch(this.stateUrlValue, 'patch', { furnace: { level: newLevel } })
        await this.fetchState()
      } catch (error) {
        window.alert(this.errorSetMessageValue)
        throw error
      }
    }

    this.spinnerVisible = false
  }

  // eslint-disable-next-line accessor-pairs
  set spinnerVisible (toggle) {
    if (this.hasFurnaceFormTarget) toggleDisplay(this.furnaceFormTarget, !toggle)
    toggleDisplay(this.spinnerTarget, toggle)
  }
}
