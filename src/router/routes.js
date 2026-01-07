const routes = [
  {
    path: '/',
    component: () => import('layouts/MainLayout.vue'),
    children: [
      { path: '', component: () => import('pages/IndexPage.vue') },
      {
        path: '',
        name: 'home',
        component: () => import('pages/IndexPage.vue'),
      },
      {
        path: 'gallery',
        name: 'gallery',
        component: () => import('pages/GalleryPage.vue'),
      },
      {
        path: 'add',
        name: 'addpiece',
        component: () => import('pages/AddPiecePage.vue'),
      },
      {
        path: 'shelf',
        name: 'shelf',
        component: () => import('pages/ShelfBoardPage.vue'),
      },
      {
        path: 'glazes',
        name: 'glazeInventory',
        component: () => import('pages/GlazeInventoryPage.vue'),
      },
      {
        path: 'glazes/all',
        name: 'allGlazes',
        component: () => import('pages/AllGlazesPage.vue'),
      },
      {
        path: 'login',
        name: 'login',
        component: () => import('pages/LoginPage.vue'),
      },
      {
        path: 'logout',
        name: 'logout',
        component: () => import('pages/LogoutPage.vue'),
      },
      {
        path: 'profile',
        name: 'profile',
        component: () => import('pages/ProfilePage.vue'),
      },
      {
        path: 'viewpiece',
        name: 'viewpiece',
        component: () => import('pages/ViewPiece.vue'),
      },
      // Bandanas routes
      {
        path: 'bandanas',
        name: 'bandanas-home',
        component: () => import('pages/BandanasHomePage.vue'),
      },
      {
        path: 'bandanas/buyers',
        name: 'bandanas-buyers',
        component: () => import('pages/BandanasBuyersPage.vue'),
      },
      {
        path: 'bandanas/buyers/:id',
        name: 'bandanas-buyer-edit',
        component: () => import('pages/BandanasBuyerEditPage.vue'),
      },
      {
        path: 'bandanas/buyers/:id/detail',
        name: 'bandanas-buyer-detail',
        component: () => import('pages/BandanasBuyerDetailPage.vue'),
      },
      {
        path: 'bandanas/addresses',
        name: 'bandanas-addresses',
        component: () => import('pages/BandanasBuyerAddressesPage.vue'),
      },
      {
        path: 'bandanas/addresses/:id',
        name: 'bandanas-address-edit',
        component: () => import('pages/BandanasBuyerAddressEditPage.vue'),
      },
      {
        path: 'bandanas/events',
        name: 'bandanas-events',
        component: () => import('pages/BandanasEventsPage.vue'),
      },
      {
        path: 'bandanas/events/:id',
        name: 'bandanas-event-edit',
        component: () => import('pages/BandanasEventEditPage.vue'),
      },
      {
        path: 'bandanas/orders',
        name: 'bandanas-orders',
        component: () => import('pages/BandanasOrdersPage.vue'),
      },
      {
        path: 'bandanas/orders/:id',
        name: 'bandanas-order-edit',
        component: () => import('pages/BandanasOrderEditPage.vue'),
      },
    ],
  },

  // catch all 404
  {
    path: '/:catchAll(.*)*',
    component: () => import('pages/ErrorNotFound.vue'),
  },
]

export default routes
