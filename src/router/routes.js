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
    ],
  },

  // catch all 404
  {
    path: '/:catchAll(.*)*',
    component: () => import('pages/ErrorNotFound.vue'),
  },
]

export default routes
