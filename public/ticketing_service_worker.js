const openDB = async () => {
  const request = indexedDB.open('ticketing', 1)

  return new Promise((resolve, reject) => {
    request.onerror = e => {
      reject(e)
    }

    request.onupgradeneeded = e => {
      const db = e.target.result
      const valuesStore = db.createObjectStore('values', { keyPath: 'name' })

      valuesStore.transaction.oncomplete = () => {
        const values = db.transaction('values', 'readwrite').objectStore('values')
        storeBadgeValue(values, 0)
      }

      valuesStore.transaction.onerror = e => {
        reject(e)
      }
    }

    request.onsuccess = e => {
      resolve(e.target.result)
    }
  })
}

const fetchBadgeValue = async () => {
  const db = await openDB()
  const values = db.transaction('values', 'readwrite').objectStore('values')
  const badgeValue = values.get('badge_value')
  return new Promise((resolve, reject) => {
    badgeValue.onsuccess = e => resolve(e)
    badgeValue.onerror = e => reject(e)
  })
}

const storeBadgeValue = (store, value) => {
  store.put({ name: 'badge_value', value })
}

const clearBadge = async () => {
  if (!navigator.clearAppBadge) return

  // eslint-disable-next-line compat/compat
  navigator.clearAppBadge()
  const ev = await fetchBadgeValue()
  storeBadgeValue(ev.target.source, 0)
}

const updateBadge = async () => {
  if (!navigator.setAppBadge) return

  const ev = await fetchBadgeValue()
  const newBadgeValue = ev.target.result.value + 1
  // eslint-disable-next-line compat/compat
  navigator.setAppBadge(newBadgeValue)
  storeBadgeValue(ev.target.source, newBadgeValue)
}

self.addEventListener('message', async e => {
  if (e.data !== 'opened_app') return

  clearBadge()
})

self.addEventListener('push', async e => {
  const { title, body, order_url: orderUrl } = await e.data.json()
  self.registration.showNotification(title, { body, data: { orderUrl } })

  updateBadge()
})

self.addEventListener('notificationclick', e => {
  e.notification.close()
  e.waitUntil(
    self.clients.openWindow(e.notification.data.orderUrl).then(windowClient => {
      if (windowClient) windowClient.focus()
    })
  )

  clearBadge()
})
