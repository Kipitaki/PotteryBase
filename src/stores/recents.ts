import { defineStore } from 'pinia'
import { ref } from 'vue'

export type FiringTemplate = {
  cone: string
  tempF?: number | string
  kilnType?: string
  kilnLocation?: string
}

const MAX = 6

function load<T>(key: string, def: T): T {
  try {
    return JSON.parse(localStorage.getItem(key) || JSON.stringify(def))
  } catch {
    return def
  }
}
function save<T>(key: string, v: T) {
  localStorage.setItem(key, JSON.stringify(v))
}
function upsertIds(list: string[], id: string) {
  const out = [id, ...list.filter((x) => x !== id)]
  return out.slice(0, MAX)
}
function equalFiring(a: FiringTemplate, b: FiringTemplate) {
  return (
    String(a.cone || '') === String(b.cone || '') &&
    String(a.tempF || '') === String(b.tempF || '') &&
    String(a.kilnType || '') === String(b.kilnType || '') &&
    String(a.kilnLocation || '') === String(b.kilnLocation || '')
  )
}
function upsertFirings(list: FiringTemplate[], item: FiringTemplate) {
  const out = [item, ...list.filter((x) => !equalFiring(x, item))]
  return out.slice(0, MAX)
}

export const useRecentsStore = defineStore('recents', () => {
  const glazeIds = ref<string[]>(load('pb:recent_glazes', []))
  const clayIds = ref<string[]>(load('pb:recent_clays', []))
  const firings = ref<FiringTemplate[]>(load('pb:recent_firings', []))

  function addGlaze(id: string) {
    if (!id) return
    glazeIds.value = upsertIds(glazeIds.value, id)
    save('pb:recent_glazes', glazeIds.value)
  }
  function addClay(id: string) {
    if (!id) return
    clayIds.value = upsertIds(clayIds.value, id)
    save('pb:recent_clays', clayIds.value)
  }
  function addFiring(t: FiringTemplate) {
    const norm: FiringTemplate = {
      cone: String(t.cone || ''),
      tempF: t.tempF ?? '',
      kilnType: t.kilnType ?? '',
      kilnLocation: t.kilnLocation ?? '',
    }
    if (!norm.cone && !norm.tempF && !norm.kilnType && !norm.kilnLocation) return
    firings.value = upsertFirings(firings.value, norm)
    save('pb:recent_firings', firings.value)
  }

  /** Seed once if empty (call from a boot file or a page) */
  function seedIfEmpty(
    seed: {
      glazeIds?: string[]
      clayIds?: string[]
      firings?: FiringTemplate[]
    } = {},
  ) {
    let changed = false
    if (glazeIds.value.length === 0 && seed.glazeIds?.length) {
      glazeIds.value = seed.glazeIds.slice(0, MAX)
      save('pb:recent_glazes', glazeIds.value)
      changed = true
    }
    if (clayIds.value.length === 0 && seed.clayIds?.length) {
      clayIds.value = seed.clayIds.slice(0, MAX)
      save('pb:recent_clays', clayIds.value)
      changed = true
    }
    if (firings.value.length === 0 && seed.firings?.length) {
      // de-dup + cap
      const unique: FiringTemplate[] = []
      seed.firings.forEach((t) => {
        if (!unique.some((u) => equalFiring(u, t))) unique.push(t)
      })
      firings.value = unique.slice(0, MAX)
      save('pb:recent_firings', firings.value)
      changed = true
    }
    return changed
  }

  /** Optional helper while testing */
  function reset() {
    glazeIds.value = []
    save('pb:recent_glazes', glazeIds.value)
    clayIds.value = []
    save('pb:recent_clays', clayIds.value)
    firings.value = []
    save('pb:recent_firings', firings.value)
  }

  return { glazeIds, clayIds, firings, addGlaze, addClay, addFiring, seedIfEmpty, reset }
})
