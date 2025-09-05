import { boot } from 'quasar/wrappers'
import { createApolloClient } from '@nhost/apollo'
import { DefaultApolloClient } from '@vue/apollo-composable'
import { nhost } from './nhost'

const apolloClient = createApolloClient({
  nhost,
  connectToDevTools: true,
})

export default boot(({ app }) => {
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

export { apolloClient }
