import Step from 'components/ticketing/orders/step'
import { toggleDisplay, togglePluralText } from 'components/utils'

export default class extends Step {
  constructor (delegate) {
    super('coupons', delegate)

    this.info.api = {
      coupons: []
    }

    this.couponTemplate = this.box.querySelector('.coupon').cloneNode(true)

    this.box.addEventListener('change', event => {
      if (event.target.tagName === 'SELECT') this.updateTotals()
    })
    this.box.querySelector('.add-coupon').addEventListener('click', event => {
      this.addCoupon()
      event.preventDefault()
    })
    this.box.addEventListener('click', event => {
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

    togglePluralText(this.box.querySelector('.total .plural_text'), numberOfCoupons)

    const formattedTotal = this.formatCurrency(total)
    this.box.querySelector('.total .total span').textContent = formattedTotal
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
  }

  updateRemoveLinks () {
    const multipleCoupons = this.couponRows.length > 1
    toggleDisplay(this.box.querySelector('.remove-coupon'), multipleCoupons)
  }

  get couponRows () {
    return this.box.querySelectorAll(':scope .coupon')
  }
}
