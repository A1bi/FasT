import Step from './step'
import { togglePluralText } from '../../utils'
import $ from 'jquery'

export default class extends Step {
  constructor (delegate) {
    super('coupons', delegate)

    this.info.api = {
      coupons: []
    }

    this.couponTemplate = this.box.find('.coupon').clone()

    this.box.on('change', 'select', () => this.updateTotals())
    this.box.find('.add-coupon').click(event => {
      this.addCoupon()
      event.preventDefault()
    })
    this.box.on('click', '.remove-coupon', event => {
      this.removeCoupon(event.currentTarget)
      event.preventDefault()
    })

    this.updateTotals()
    this.updateRemoveLinks()
  }

  updateTotals () {
    this.info.api.coupons = []
    var total = 0
    var numberOfCoupons = 0

    this.box.find('.coupon').each((_, couponRow) => {
      couponRow = $(couponRow)
      const number = parseInt(couponRow.find('#number').val())
      const value = parseFloat(couponRow.find('#value').val())
      const couponTotal = number * value
      const formattedTotal = this.formatCurrency(couponTotal)

      this.info.api.coupons.push({ number: number, value: value })
      couponRow.find('.total span').text(formattedTotal)
      numberOfCoupons += number
      total += couponTotal
    })

    togglePluralText(
      this.box.find('.total .plural_text'), numberOfCoupons
    )

    const formattedTotal = this.formatCurrency(total)
    this.box.find('.total .total span').text(formattedTotal)
  }

  addCoupon () {
    const coupon = this.couponTemplate.clone()
    this.box.find('.coupon').last().after(coupon)
    this.updateList()
  }

  removeCoupon (row) {
    row = $(row)
    row.parents('.coupon').remove()
    this.updateList()
  }

  updateList () {
    this.updateTotals()
    this.updateRemoveLinks()
    this.resizeDelegateBox(true)
  }

  updateRemoveLinks () {
    const multipleCoupons = this.box.find('.coupon').length > 1
    this.box.find('.remove-coupon').toggle(multipleCoupons)
  }
}
