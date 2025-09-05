// stores/catalog-factory.ts
import { defineStore } from 'pinia'
import { ref, Ref } from 'vue'

/**
 * Base type for catalog items
 */
export interface CatalogItem {
  id: string
  name: string
  [key: string]: any
}

interface CatalogConfig<T extends CatalogItem> {
  id: string // Pinia store id
  storageKey: string // localStorage key
  prefix: string // id prefix ("g", "c", "f")
  defaults: Omit<T, 'id'>[] // defaults without ids (factory will assign ids)
  makeLabel: (item: T) => string
}

export function makeCatalogStore<T extends CatalogItem>(config: CatalogConfig<T>) {
  const uid = () =>
    `${config.prefix}${Date.now().toString(36)}${Math.random().toString(36).slice(2, 7)}`

  const load = (): T[] => {
    try {
      return JSON.parse(localStorage.getItem(config.storageKey) || '[]') as T[]
    } catch {
      return []
    }
  }

  const save = (v: T[]) => localStorage.setItem(config.storageKey, JSON.stringify(v))

  return defineStore(config.id, () => {
    // NOTE: items is Ref<T[]> but initialized from load()
    const items: Ref<T[]> = ref(load()) as Ref<T[]>

    // Seed defaults if empty
    if (items.value.length === 0) {
      items.value = config.defaults.map((d) => ({ ...d, id: uid() }) as T)
      save(items.value)
    }

    function create(data: Partial<T>) {
      const created = {
        ...(data as T),
        id: uid(),
        name: (data.name || '').trim(),
      } as T
      items.value = [...items.value, created]
      save(items.value)
      return created
    }

    function update(id: string, patch: Partial<T>) {
      items.value = items.value.map((it) => (it.id === id ? ({ ...it, ...patch } as T) : it))
      save(items.value)
    }

    function remove(id: string) {
      items.value = items.value.filter((it) => it.id !== id)
      save(items.value)
    }

    function resetToDefaults() {
      items.value = config.defaults.map((d) => ({ ...d, id: uid() }) as T)
      save(items.value)
    }

    const options = () =>
      items.value.map((it) => ({
        id: it.id,
        label: config.makeLabel(it),
      }))

    return { items, create, update, remove, resetToDefaults, options }
  })
}
