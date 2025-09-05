<template>
  <q-layout view="lHh lpr lFf">
    <navigation-bar />

    <q-page-container>
      <router-view />
    </q-page-container>
  </q-layout>
</template>

<script setup>
import NavigationBar from 'src/components/NavigationBar.vue'
</script>
