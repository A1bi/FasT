export const isIE = () => {
  const agent = navigator.userAgent
  return navigator.appName === 'Microsoft Internet Explorer' ||
  !!(agent.match(/Trident/) || agent.match(/rv:11/))
}

export const togglePluralText = (box, number) => {
  const plural = number !== 1
  box.toggleClass('plural', plural).toggleClass('singular', !plural)
  box.find('.number span').text(number)
}

export const fetch = async (url, method, data) => {
  const token =
      document.querySelector('meta[name="csrf-token"]').getAttribute('content')
  const response = await window.fetch(url, {
    method: method.toUpperCase(),
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': token
    },
    body: JSON.stringify(data)
  })

  if (!response.ok) throw response

  const type = response.headers.get('Content-Type')
  if (type && type.indexOf('json') > -1) {
    return response.json()
  }
}
