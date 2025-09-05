import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { seedPotteryItems, seedLikedIds, seedStats, seedActivity } from 'src/fixtures/pottery'

// local storage key (so data survives page refresh)
const STORAGE_KEY = 'pb_pottery_store_v1'

export const usePotteryStore = defineStore('pottery', () => {
  // state
  const items = ref<any[]>([])
  const likedIds = ref<number[]>([])
  const stats = ref<{ formed: number; trimmed: number; glazed: number; fired: number }>({
    formed: 0,
    trimmed: 0,
    glazed: 0,
    fired: 0,
  })
  const activity = ref<any[]>([])

  // getters
  const likedSet = computed(() => new Set(likedIds.value))
  const featured = computed(() => items.value.slice(0, 12))

  // actions
  function seedIfEmpty() {
    const saved = localStorage.getItem(STORAGE_KEY)
    if (saved) {
      const data = JSON.parse(saved)
      items.value = data.items || []
      likedIds.value = data.likedIds || []
      stats.value = data.stats || stats.value
      activity.value = data.activity || []
      return
    }
    // load from fixtures
    items.value = seedPotteryItems
    likedIds.value = seedLikedIds
    stats.value = seedStats
    activity.value = seedActivity
    persist()
  }

  function persist() {
    localStorage.setItem(
      STORAGE_KEY,
      JSON.stringify({
        items: items.value,
        likedIds: likedIds.value,
        stats: stats.value,
        activity: activity.value,
      }),
    )
  }

  function toggleLike(id: number) {
    const i = likedIds.value.indexOf(id)
    if (i >= 0) likedIds.value.splice(i, 1)
    else likedIds.value.push(id)
    persist()
  }
  function addItem(item: {
    name: string
    description: string
    stage: 'Formed' | 'Trimmed' | 'Bisque' | 'Glazed' | 'Fired'
    image: string
    tags: string[]
  }) {
    const nextId = items.value.length ? Math.max(...items.value.map((i: any) => i.id || 0)) + 1 : 1

    items.value.unshift({ id: nextId, ...item })
    persist()
    return nextId
  }

  return {
    items,
    likedIds,
    stats,
    activity,
    likedSet,
    featured,
    seedIfEmpty,
    toggleLike,
    addItem,
  }
})
