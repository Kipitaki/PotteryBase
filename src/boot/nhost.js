// src/boot/nhost.js
import { boot } from 'quasar/wrappers'
import { NhostClient } from '@nhost/vue'
import { createApolloClient } from '@nhost/apollo'
import { DefaultApolloClient } from '@vue/apollo-composable'

// Environment-based Nhost configuration
// Check for local development - include both localhost and 127.0.0.1
const isLocal =
  process.env.NODE_ENV === 'development' &&
  (window.location.hostname === 'localhost' ||
    window.location.hostname === '127.0.0.1' ||
    window.location.hostname.includes('local.nhost.run'))

console.log(
  '[Nhost Config] isLocal:',
  isLocal,
  'hostname:',
  window.location.hostname,
  'NODE_ENV:',
  process.env.NODE_ENV,
)

const nhostConfig = isLocal
  ? {
      // LOCAL DEVELOPMENT: Use all local services via Traefik
      // Traefik routes all *.local.nhost.run domains to local services
      graphqlUrl: 'https://local.hasura.local.nhost.run/v1/graphql',
      authUrl: 'https://local.auth.local.nhost.run/v1',
      storageUrl: 'https://local.storage.local.nhost.run/v1',
      functionsUrl: 'https://local.functions.local.nhost.run/v1',
      autoSignIn: true,
    }
  : {
      // PRODUCTION: Use remote Nhost services
      subdomain: 'tmrlxlwvkpqbgbgfoysh',
      region: 'us-east-1',
      autoSignIn: true,
    }

console.log('[Nhost Config] Using config:', JSON.stringify(nhostConfig, null, 2))

export const nhost = new NhostClient(nhostConfig)

// Log the actual URLs being used after client creation
console.log('[Nhost Client] Auth URL:', nhost.auth.url)
console.log('[Nhost Client] GraphQL URL:', nhost.graphql.getUrl())

// Build Apollo client once auth is ready
const apolloClientPromise = nhost.auth.waitUntilReady().then(async () => {
  const client = createApolloClient({
    nhost,
    connectToDevTools: true,
    cacheConfig: {
      typePolicies: {
        potterbase_piece: {
          fields: {
            piece_stage_histories: {
              // eslint-disable-next-line no-unused-vars
              merge(oldData = [], freshData) {
                return freshData
              },
            },
            piece_glazes: {
              // eslint-disable-next-line no-unused-vars
              merge(oldData = [], freshData) {
                return freshData
              },
            },
            piece_firings: {
              // eslint-disable-next-line no-unused-vars
              merge(oldData = [], freshData) {
                return freshData
              },
            },
            piece_images: {
              // eslint-disable-next-line no-unused-vars
              merge(oldData = [], freshData) {
                return freshData
              },
            },
            piece_clays: {
              // eslint-disable-next-line no-unused-vars
              merge(oldData = [], freshData) {
                return freshData
              },
            },
          },
        },
      },
    },
  })

  // Force schema introspection to refresh cached schema
  // This ensures Apollo sees new fields like is_for_sale, price, in_stock
  try {
    const gql = require('graphql-tag').default
    await client.query({
      query: gql`
        query IntrospectPiece {
          __type(name: "potterbase_piece") {
            fields {
              name
            }
          }
        }
      `,
      fetchPolicy: 'network-only',
      errorPolicy: 'ignore', // Don't fail if introspection fails
    })
    console.log('[Apollo] Schema introspection completed')
  } catch (err) {
    console.warn('[Apollo] Schema introspection failed (may be normal):', err)
  }

  return client
})

export default boot(async ({ app }) => {
  const apolloClient = await apolloClientPromise

  // Register Nhost + Apollo with Vue
  app.use(nhost)
  app.provide(DefaultApolloClient, apolloClient)

  // Debug: Log the actual GraphQL URL being used
  console.log('[Apollo] GraphQL URL:', nhost.graphql.getUrl())

  // Don't clear store during boot - it causes "Store reset while query was in flight" errors
  // Schema will refresh naturally when queries execute with fetchPolicy: 'network-only'

  // Don't reset store on sign-in - it causes errors when schema is cached
  // Queries will naturally refresh with fetchPolicy: 'network-only'
  // nhost.auth.onAuthStateChanged(async (event) => {
  //   if (event === 'SIGNED_IN') {
  //     // Schema caching issue - don't reset store
  //   }
  // })

  // Debug confirmation
  console.log(`✅ Nhost running in ${isLocal ? 'LOCAL' : 'PRODUCTION'} mode`)
})

export { apolloClientPromise as apolloClient }
