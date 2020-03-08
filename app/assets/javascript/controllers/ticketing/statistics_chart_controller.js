import { Controller } from 'stimulus'
import Chart from 'chart.js'

export default class extends Controller {
  static targets = ['canvas']

  static chartColors = {
    red: 'rgb(255, 99, 132)',
    green: 'rgb(75, 192, 192)',
    blue: 'rgb(54, 162, 235)'
  }

  static colorOrder = ['green', 'red', 'blue']

  async connect () {
    await this.fetchData()
    this.createChart()
  }

  async fetchData () {
    const path = this.data.get('data-path')
    const response = await window.fetch(path)
    this.chartData = await response.json()

    this.chartData.datasets.forEach((dataset, index) => {
      const colorIndex = this.constructor.colorOrder[index]
      dataset.backgroundColor = this.constructor.chartColors[colorIndex]
      dataset.borderColor = dataset.backgroundColor
    })
  }

  createChart () {
    this.chart = new Chart(this.canvasTarget, {
      type: 'line',
      data: this.chartData,
      options: {
        datasets: {
          line: {
            lineTension: 0
          }
        },
        tooltips: {
          mode: 'index'
        },
        scales: {
          yAxes: [{
            stacked: true,
            scaleLabel: {
              display: true,
              labelString: 'Verkaufte Tickets'
            }
          }]
        }
      }
    })
  }
}
