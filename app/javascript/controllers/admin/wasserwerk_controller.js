import { Controller } from '@hotwired/stimulus'
import { toggleDisplay, fetch } from 'components/utils'

export default class extends Controller {
  static targets = [
    'furnaceLevelLabel', 'furnaceOffLabel', 'furnaceScaleStep', 'furnaceForm', 'furnaceLevelInput', 'spinner',
    'stageTemperature', 'stageHumidity', 'costumesTemperature', 'costumesHumidity'
  ]

  static values = {
    stateUrl: String,
    onPrompt: String,
    offPrompt: String,
    errorFetchMessage: String,
    errorSetMessage: String
  }

  async connect () {
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
    const state = await fetch(this.stateUrlValue)
    this.furnaceLevel = state.furnace.level

    this.updateFurnaceState()
    this.updateTemperatures(state)
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

  updateTemperatures (state) {
    ['stage', 'costumes'].forEach(location => {
      this[`${location}TemperatureTarget`].innerText = state.temperatures[location].toLocaleString('de-DE')
      this[`${location}HumidityTarget`].innerText = Math.round(state.humidities[location])
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
      return
    }

    try {
      await fetch(this.stateUrlValue, 'patch', { furnace: { level: newLevel } })
      await this.fetchState()
    } catch (error) {
      window.alert(this.errorSetMessageValue)
      throw error
    }

    this.spinnerVisible = false
  }

  // eslint-disable-next-line accessor-pairs
  set spinnerVisible (toggle) {
    if (this.hasFurnaceFormTarget) toggleDisplay(this.furnaceFormTarget, !toggle)
    toggleDisplay(this.spinnerTarget, toggle)
  }
}
