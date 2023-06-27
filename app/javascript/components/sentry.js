let baseUrl
let dsn
let eventId

const breadcrumbs = []

const uuidv4 = () => {
  if (crypto && crypto.randomUUID) {
    return crypto.randomUUID().replace(/-/g, '')
  }

  return ([1e7] + 1e3 + 4e3 + 8e3 + 1e11).replace(/[018]/g, c =>
    (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16)
  )
}

const time = () => {
  return new Date().toISOString()
}

const envelopeHeaders = () => {
  return {
    event_id: eventId,
    dsn,
    sent_at: time()
  }
}

const itemHeaders = () => {
  return {
    type: 'event'
  }
}

const itemPayload = (item) => {
  return {
    ...item,
    event_id: eventId,
    platform: 'javascript',
    timestamp: time(),
    environment: 'production',
    breadcrumbs: {
      values: breadcrumbs
    },
    request: {
      url: window.location.href,
      headers: {
        Referer: document.referrer,
        'User-Agent': window.navigator.userAgent
      }
    }
  }
}

const sendEnvelope = async (item) => {
  if (window.location.href.match(/https?:\/\/localhost/)) return

  const url = `${baseUrl}/api/1/envelope/`
  const envelope = [envelopeHeaders(), itemHeaders(), itemPayload(item)]
  const body = envelope.map(d => JSON.stringify(d)).join('\n')

  await window.fetch(url, {
    method: 'POST',
    body
  })
}

export const captureException = (error, mechanism) => {
  const frames = error.error.stack.split('\n').map(frame => {
    const parts = frame.match(/(.+?)@(.+)/)
    const location = parts[2].match(/(.+):(\d+):(\d+)$/)
    return {
      filename: location[1],
      function: parts[1],
      lineno: parseInt(location[2]),
      colno: parseInt(location[3])
    }
  })

  sendEnvelope({
    exception: {
      values: [
        {
          type: error.error.name,
          value: error.error.message,
          stacktrace: {
            frames
          },
          mechanism: {
            type: mechanism,
            handled: false
          }
        }
      ]
    },
    level: 'error'
  })
}

export const captureMessage = (message, data) => {
  eventId = uuidv4()

  sendEnvelope({
    message,
    level: 'info',
    ...data
  })
}

export const addBreadcrumb = (data) => {
  breadcrumbs.push({
    ...data,
    timestamp: time()
  })
}

export const init = (options) => {
  baseUrl = options.dsn.replace(/(https:\/\/).+?@(.+?)\/.+/, '$1$2')
  dsn = options.dsn

  window.addEventListener('error', e => captureException(e, 'onerror'))
  window.addEventListener('unhandledrejection ', e => captureException(e, 'onunhandledrejection'))
}
