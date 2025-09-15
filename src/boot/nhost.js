// src/boot/nhost.js
import { boot } from 'quasar/wrappers'
import { NhostClient } from '@nhost/vue'
import { createApolloClient } from '@nhost/apollo'
import { DefaultApolloClient } from '@vue/apollo-composable'

// Local-only Nhost configuration
export const nhost = new NhostClient({
  subdomain: 'local',
  region: 'local',
  autoSignIn: true, // restore session instantly

  graphqlUrl: 'http://localhost:8080/v1/graphql',
  authUrl: 'http://localhost:4000/v1/auth',
  storageUrl: 'http://localhost:5000/v1/storage',
  functionsUrl: 'http://localhost:3000/v1/functions',
})

// Build Apollo client once auth is ready
const apolloClientPromise = nhost.auth.waitUntilReady().then(() => {
  return createApolloClient({
    nhost,
    connectToDevTools: true,
  })
})

export default boot(async ({ app }) => {
  const apolloClient = await apolloClientPromise

  // Register Nhost + Apollo with Vue
  app.use(nhost)
  app.provide(DefaultApolloClient, apolloClient)

  // Reset Apollo cache on sign-in
  nhost.auth.onAuthStateChanged(async (event) => {
    if (event === 'SIGNED_IN') {
      try {
        await apolloClient.resetStore()
      } catch (err) {
        console.error('[Apollo] resetStore failed:', err)
      }
    }
  })

  // Debug confirmation
  console.log('✅ Nhost running in LOCAL mode (localhost services only)')
})

export { apolloClientPromise as apolloClient }
