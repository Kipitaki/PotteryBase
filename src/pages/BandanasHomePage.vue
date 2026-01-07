<template>
  <q-page padding class="bg-grey-1 bandanas-page">
    <div class="row items-center justify-between q-mb-md">
      <div>
        <div class="text-h4 text-weight-bold">Bandanas Management</div>
        <div class="text-caption text-grey-7 q-mt-xs">
          Manage buyers, addresses, events, and orders
        </div>
      </div>
    </div>

    <div class="row q-col-gutter-md">
      <!-- Buyers Card -->
      <div class="col-12 col-md-6 col-lg-3">
        <q-card
          class="cursor-pointer bandanas-card"
          @click="router.push({ name: 'bandanas-buyers' })"
        >
          <q-card-section>
            <div class="row items-center q-mb-sm">
              <q-icon name="people" size="48px" color="purple" class="q-mr-md" />
              <div>
                <div class="text-h6 text-weight-bold">Buyers</div>
                <div class="text-caption text-grey-7">Manage buyer information</div>
              </div>
            </div>
          </q-card-section>
          <q-card-section class="q-pt-none">
            <div class="text-body2 text-grey-7">
              Add, edit, and manage buyer profiles and contact information.
            </div>
          </q-card-section>
        </q-card>
      </div>

      <!-- Addresses Card -->
      <div class="col-12 col-md-6 col-lg-3">
        <q-card
          class="cursor-pointer bandanas-card"
          @click="router.push({ name: 'bandanas-addresses' })"
        >
          <q-card-section>
            <div class="row items-center q-mb-sm">
              <q-icon name="home" size="48px" color="purple" class="q-mr-md" />
              <div>
                <div class="text-h6 text-weight-bold">Addresses</div>
                <div class="text-caption text-grey-7">Shipping addresses</div>
              </div>
            </div>
          </q-card-section>
          <q-card-section class="q-pt-none">
            <div class="text-body2 text-grey-7">Manage shipping addresses for buyers.</div>
          </q-card-section>
        </q-card>
      </div>

      <!-- Events Card -->
      <div class="col-12 col-md-6 col-lg-3">
        <q-card
          class="cursor-pointer bandanas-card"
          @click="router.push({ name: 'bandanas-events' })"
        >
          <q-card-section>
            <div class="row items-center q-mb-sm">
              <q-icon name="event" size="48px" color="purple" class="q-mr-md" />
              <div>
                <div class="text-h6 text-weight-bold">Events</div>
                <div class="text-caption text-grey-7">Bandana events & pricing</div>
              </div>
            </div>
          </q-card-section>
          <q-card-section class="q-pt-none">
            <div class="text-body2 text-grey-7">Manage events, pricing, and availability.</div>
          </q-card-section>
        </q-card>
      </div>

      <!-- Orders Card -->
      <div class="col-12 col-md-6 col-lg-3">
        <q-card
          class="cursor-pointer bandanas-card"
          @click="router.push({ name: 'bandanas-orders' })"
        >
          <q-card-section>
            <div class="row items-center q-mb-sm">
              <q-icon name="shopping_cart" size="48px" color="purple" class="q-mr-md" />
              <div>
                <div class="text-h6 text-weight-bold">Orders</div>
                <div class="text-caption text-grey-7">Customer orders</div>
              </div>
            </div>
          </q-card-section>
          <q-card-section class="q-pt-none">
            <div class="text-body2 text-grey-7">View and manage customer orders.</div>
          </q-card-section>
        </q-card>
      </div>
    </div>
  </q-page>
</template>

<script setup>
import { useRouter } from 'vue-router'

const router = useRouter()
</script>

<style scoped>
.bandanas-card {
  transition:
    transform 0.2s,
    box-shadow 0.2s;
}

.bandanas-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 12px rgba(156, 39, 176, 0.3);
}
</style>
