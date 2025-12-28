// Re-export apolloClient from nhost.js to ensure all stores use the same instance
// This prevents multiple Apollo clients with different configurations
// The client in nhost.js is created asynchronously after auth is ready
// Note: This is a Promise - stores should await it or use it in async contexts
export { apolloClient } from './nhost'

import { boot } from 'quasar/wrappers'

// Note: Apollo client is created in nhost.js boot file (asynchronously after auth is ready)
// This file just re-exports it for backward compatibility with stores
// that import from 'boot/apollo'
export default boot(async () => {
  // Apollo client is already provided in nhost.js boot file
  // No additional setup needed here
})
