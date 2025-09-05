import { boot } from 'quasar/wrappers'
import { useRecentsStore } from 'src/stores/recents'
import { useGlazesStore } from 'src/stores/glazes'
import { useClaysStore } from 'src/stores/clays'

export default boot(() => {
  const recents = useRecentsStore()
  const glazes  = useGlazesStore()
  const clays   = useClaysStore()

  // pick first few from stores (if populated)
  const glazeIds = glazes.glazes.slice(0, 4).map(g => g.id)
  const clayIds  = clays.clays.slice(0, 4).map(c => c.id)

  // some useful default firing templates
  const firingTemplates = [
    { cone: '06', tempF: 1828, kilnType: 'Electric', kilnLocation: 'Studio A' },
    { cone: '5',  tempF: 2167, kilnType: 'Electric', kilnLocation: 'Studio B' },
    { cone: '10', tempF: 2345, kilnType: 'Gas',      kilnLocation: 'Community Kiln' }
  ]

  recents.seedIfEmpty({
    glazeIds,
    clayIds,
    firings: firingTemplates
  })
})
