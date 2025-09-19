import { boot } from 'quasar/wrappers'
import { createApolloClient } from '@nhost/apollo'
import { DefaultApolloClient } from '@vue/apollo-composable'
import { nhost } from './nhost'

const apolloClient = createApolloClient({
  nhost,
  connectToDevTools: true,
  cacheConfig: {
    typePolicies: {
      potterbase_piece: {
        fields: {
          piece_stage_histories: {
            // eslint-disable-next-line no-unused-vars
            merge(oldData = [], freshData) {
              // Replace strategy: use fresh server data, ignore old cached data
              return freshData
            },
          },
          piece_glazes: {
            // eslint-disable-next-line no-unused-vars
            merge(oldData = [], freshData) {
              // Replace strategy: use fresh server data, ignore old cached data
              return freshData
            },
          },
          piece_firings: {
            // eslint-disable-next-line no-unused-vars
            merge(oldData = [], freshData) {
              // Replace strategy: use fresh server data, ignore old cached data
              return freshData
            },
          },
          piece_images: {
            // eslint-disable-next-line no-unused-vars
            merge(oldData = [], freshData) {
              // Replace strategy: use fresh server data, ignore old cached data
              return freshData
            },
          },
          piece_clays: {
            // eslint-disable-next-line no-unused-vars
            merge(oldData = [], freshData) {
              // Replace strategy: use fresh server data, ignore old cached data
              return freshData
            },
          },
        },
      },
    },
  },
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
