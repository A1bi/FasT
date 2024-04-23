export const toggleDisplay = (el, toggle) => {
  el.classList.toggle('d-none', !toggle)
}

export const toggleDisplayIfExists = (el, toggle) => {
  if (el) toggleDisplay(el, toggle)
}

export const togglePluralText = (box, number) => {
  if (!box.querySelector) box = box[0]
  if (!box.matches('.plural_text')) box = box.querySelector('.plural_text')
  const plural = number !== 1
  box.classList.toggle('plural', plural)
  box.classList.toggle('singular', !plural)
  box.querySelectorAll(':scope .number span').forEach(el => { el.textContent = number })
}

export const getAuthenticityToken = () => {
  return document.querySelector('meta[name="csrf-token"]').getAttribute('content')
}

export const fetch = async (url, method = 'get', data, cache = 'default') => {
  const response = await window.fetch(url, {
    method: method.toUpperCase(),
    headers: {
      Accept: 'application/json',
      'Content-Type': 'application/json',
      'X-CSRF-Token': getAuthenticityToken()
    },
    body: data ? (typeof data === 'string' ? data : JSON.stringify(data)) : null,
    cache
  })

  let json = null
  const type = response.headers.get('Content-Type')
  const length = Number(response.headers.get('Content-Length'))
  if (response.status !== 204 && length > 0 && type && type.indexOf('json') > -1) {
    json = await response.json()
  }

  if (!response.ok) {
    response.data = json
    throw response
  }

  return json
}

export const fetchRaw = async (url) => {
  const response = await window.fetch(url)
  if (!response.ok) throw response

  return response.text()
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
