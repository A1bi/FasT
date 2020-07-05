import { Controller } from 'stimulus'
import { fetch } from '../../components/utils'

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
    this.chartData = await fetch(path)

    this.chartData.datasets.forEach((dataset, index) => {
      const colorIndex = this.constructor.colorOrder[index]
      dataset.backgroundColor = this.constructor.chartColors[colorIndex]
      dataset.borderColor = dataset.backgroundColor
    })
  }

  async createChart () {
    const chartjs = await import('chart.js/dist/Chart.js')

    this.chart = new chartjs.Chart(this.canvasTarget, {
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
