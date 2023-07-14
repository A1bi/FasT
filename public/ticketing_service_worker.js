self.addEventListener('push', async e => {
  const { title, body, order_url: orderUrl } = await e.data.json()
  self.registration.showNotification(title, { body, data: { orderUrl } })
})

self.addEventListener('notificationclick', e => {
  e.notification.close()
  e.waitUntil(
    self.clients.openWindow(e.notification.data.orderUrl).then(windowClient => {
      if (windowClient) windowClient.focus()
    })
  )
})
