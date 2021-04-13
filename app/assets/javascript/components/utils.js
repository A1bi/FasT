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

export const testWebPSupport = (callback) => {
  return new Promise((resolve, reject) => {
    const webP = new window.Image()
    webP.src = 'data:image/webp;base64,UklGRi4AAABXRUJQVlA4TCEAAAAvAUAAEB8wA' +
               'iMwAgSSNtse/cXjxyCCmrYNWPwmHRH9jwMA'
    webP.onload = webP.onerror = () => resolve(webP.height === 2)
  })
}
