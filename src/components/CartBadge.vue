<template>
  <q-btn
    flat
    round
    icon="shopping_cart"
    :to="{ name: 'cart' }"
  >
    <q-badge
      v-if="cartStore.itemCount > 0"
      color="red"
      :label="cartStore.itemCount"
      floating
      rounded
    />
    <q-tooltip>Shopping Cart ({{ cartStore.itemCount }} items)</q-tooltip>
  </q-btn>
</template>

<script setup>
import { useCartStore } from 'src/stores/cart'

const cartStore = useCartStore()
</script>

