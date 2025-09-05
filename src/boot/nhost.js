// src/boot/nhost.js
import { boot } from 'quasar/wrappers'
import { NhostClient } from '@nhost/vue'
import { createApolloClient } from '@nhost/apollo'
import { DefaultApolloClient } from '@vue/apollo-composable'

// Create Nhost client
export const nhost = new NhostClient({
  subdomain: 'tmrlxlwvkpqbgbgfoysh',
  region: 'us-east-1',
  autoSignIn: true, // restore session instantly
})

// Wait for auth, then build Apollo
const apolloClientPromise = nhost.auth.waitUntilReady().then(() => {
  return createApolloClient({
    nhost,
    connectToDevTools: true,
  })
})

export default boot(async ({ app }) => {
  const apolloClient = await apolloClientPromise

  app.use(nhost)
  app.provide(DefaultApolloClient, apolloClient)

  // Reset Apollo when auth state changes
  nhost.auth.onAuthStateChanged(async (event) => {
    if (event === 'SIGNED_IN') {
      try {
        await apolloClient.resetStore()
      } catch (err) {
        console.error('[Apollo] resetStore failed:', err)
      }
    }
  })
})

export { apolloClientPromise as apolloClient }
