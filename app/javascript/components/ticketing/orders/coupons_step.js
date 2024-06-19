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
    this.delegate.clearLineItems()

    this.couponRows.forEach(couponRow => {
      const number = parseInt(couponRow.querySelector('#number').value)
      const value = parseFloat(couponRow.querySelector('#value').value)

      this.info.api.coupons.push({ number, value })
      const lineItem = this.delegate.addLineItem('Geschenkgutschein', value, number)
      couponRow.querySelector('.total span').textContent = this.formatCurrency(lineItem.total)
    })

    togglePluralText(this.box.querySelector('.total .plural_text'), this.delegate.numberOfArticles)

    this.delegate.orderTotal = this.delegate.lineItems.reduce((acc, item) => acc + item.total, 0)
    const formattedTotal = this.formatCurrency(this.delegate.orderTotal)
    this.box.querySelector('.total .total').textContent = formattedTotal

    this.delegate.updateBtns()
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
