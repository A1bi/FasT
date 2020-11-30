import Step from './step'
import { togglePluralText } from '../../utils'
import $ from 'jquery'

export default class extends Step {
  constructor (delegate) {
    super('coupons', delegate)

    this.info.api = {
      coupons: []
    }

    this.registerEventAndInitiate(this.box.find('select'), 'change', () => this.updateTotals())

    this.box.find('.event-header').on('load', () => this.resizeDelegateBox(true))
  }

  updateTotals () {
    this.info.api.coupons = []
    var total = 0
    var numberOfCoupons = 0

    this.box.find('tr.coupon').each((_, couponRow) => {
      couponRow = $(couponRow)
      const number = parseInt(couponRow.find('#number').val())
      const amount = parseFloat(couponRow.find('#amount').val())
      const couponTotal = number * amount
      const formattedTotal = this.formatCurrency(couponTotal)

      this.info.api.coupons.push({ number: number, amount: amount })
      couponRow.find('.total span').text(formattedTotal)
      numberOfCoupons += number
      total += couponTotal
    })

    togglePluralText(
      this.box.find('tr.total .plural_text'), numberOfCoupons
    )

    const formattedTotal = this.formatCurrency(total)
    this.box.find('tr.total .total span').text(formattedTotal)
  }
}
