import { createConsumer } from '@rails/actioncable'

let consumer

export function createSubscription (...args) {
  if (!consumer) consumer = createConsumer()
  return consumer.subscriptions.create(...args)
}
