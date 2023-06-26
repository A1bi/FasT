export const isIE = () => {
  const agent = navigator.userAgent
  return navigator.appName === 'Microsoft Internet Explorer' ||
  !!(agent.match(/Trident/) || agent.match(/rv:11/))
}

export const toggleDisplay = (el, toggle, showValue = 'block') => {
  el.style.display = toggle ? showValue : 'none'
}

export const togglePluralText = (box, number) => {
  const plural = number !== 1
  box.toggleClass('plural', plural).toggleClass('singular', !plural)
  box.find('.number span').text(number)
}

export const getAuthenticityToken = () => {
  return document.querySelector('meta[name="csrf-token"]')
    .getAttribute('content')
}

export const fetch = async (url, method = 'get', data) => {
  if (!window.fetch) await import('whatwg-fetch')

  const response = await window.fetch(url, {
    method: method.toUpperCase(),
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': getAuthenticityToken()
    },
    body: data ? JSON.stringify(data) : null
  })

  let json = null
  const type = response.headers.get('Content-Type')
  if (type && type.indexOf('json') > -1) {
    json = await response.json()
  }

  if (!response.ok) {
    response.data = json
    throw response
  }

  return json
}

export const loadVendorStylesheet = (filename) => {
  const path = `/assets/${filename}.css`
  const alreadyLoaded = [...document.styleSheets].some(sheet => sheet.href.includes(path))
  if (alreadyLoaded) return

  const link = document.createElement('link')
  link.rel = 'stylesheet'
  link.media = 'all'
  link.href = path
  document.querySelector('head').appendChild(link)
}
