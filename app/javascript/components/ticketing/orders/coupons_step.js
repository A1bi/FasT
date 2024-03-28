import Step from 'components/ticketing/orders/step'
import { toggleDisplay, togglePluralText } from 'components/utils'

export default class extends Step {
  constructor (delegate) {
    super('coupons', delegate)

    this.info.api = {
      coupons: []
    }

    this.couponTemplate = this.box[0].querySelector('.coupon').cloneNode(true)

    this.box[0].addEventListener('change', event => {
      if (event.target.tagName === 'SELECT') this.updateTotals()
    })
    this.box[0].querySelector('.add-coupon').addEventListener('click', event => {
      this.addCoupon()
      event.preventDefault()
    })
    this.box[0].addEventListener('click', event => {
      if (!event.target.matches('.remove-coupon')) return
      this.removeCoupon(event.target)
      event.preventDefault()
    })

    this.updateTotals()
    this.updateRemoveLinks()
  }

  updateTotals () {
    this.info.api.coupons = []
    let total = 0
    let numberOfCoupons = 0

    this.couponRows.forEach(couponRow => {
      const number = parseInt(couponRow.querySelector('#number').value)
      const value = parseFloat(couponRow.querySelector('#value').value)
      const couponTotal = number * value
      const formattedTotal = this.formatCurrency(couponTotal)

      this.info.api.coupons.push({ number, value })
      couponRow.querySelector('.total span').textContent = formattedTotal
      numberOfCoupons += number
      total += couponTotal
    })

    togglePluralText(this.box[0].querySelector('.total .plural_text'), numberOfCoupons)

    const formattedTotal = this.formatCurrency(total)
    this.box[0].querySelector('.total .total span').textContent = formattedTotal
  }

  addCoupon () {
    const coupon = this.couponTemplate.cloneNode(true)
    this.couponRows[this.couponRows.length - 1].after(coupon)
    this.updateList()
  }

  removeCoupon (row) {
    row.closest('.coupon').remove()
    this.updateList()
  }

  updateList () {
    this.updateTotals()
    this.updateRemoveLinks()
    this.resizeDelegateBox(true)
  }

  updateRemoveLinks () {
    const multipleCoupons = this.couponRows.length > 1
    toggleDisplay(this.box[0].querySelector('.remove-coupon'), multipleCoupons)
  }

  get couponRows () {
    return this.box[0].querySelectorAll(':scope .coupon')
  }
}
