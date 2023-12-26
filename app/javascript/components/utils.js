export const isIE = () => {
  const agent = navigator.userAgent
  return navigator.appName === 'Microsoft Internet Explorer' ||
  !!(agent.match(/Trident/) || agent.match(/rv:11/))
}

export const toggleDisplay = (el, toggle) => {
  el.classList.toggle('d-none', !toggle)
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
      Accept: 'application/json',
      'Content-Type': 'application/json',
      'X-CSRF-Token': getAuthenticityToken()
    },
    body: data ? (typeof data === 'string' ? data : JSON.stringify(data)) : null
  })

  let json = null
  const type = response.headers.get('Content-Type')
  if (response.status !== 204 && type && type.indexOf('json') > -1) {
    json = await response.json()
  }

  if (!response.ok) {
    response.data = json
    throw response
  }

  return json
}

export const loadVendorStylesheet = (path) => {
  const alreadyLoaded = [...document.styleSheets].some(sheet => sheet.href && sheet.href.includes(path))

  return new Promise((resolve, reject) => {
    if (alreadyLoaded) return resolve()

    const link = document.createElement('link')
    link.rel = 'stylesheet'
    link.media = 'all'
    link.href = path
    link.onload = resolve
    link.onerror = reject

    document.querySelector('head').appendChild(link)
  })
}
