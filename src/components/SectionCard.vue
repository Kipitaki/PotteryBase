<template>
  <q-card class="q-pa-md q-mb-md rounded-borders">
    <!-- Title + Actions aligned LEFT, side by side -->
    <div class="row items-center q-gutter-sm q-mb-sm">
      <div class="text-subtitle1"><slot name="title">Section</slot></div>
      <div><slot name="actions" /></div>
    </div>

    <slot />
  </q-card>
</template>

<script setup></script>

<style scoped>
.rounded-borders {
  border-radius: 12px;
}
</style>
