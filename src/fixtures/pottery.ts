// Demo seed data for PotteryBase with story characters

export const seedPotteryItems = [
  {
    id: 1,
    name: 'Blue Ash Mug',
    description: 'Cone 6 stoneware. Ash glaze over cobalt slip.',
    stage: 'Glazed',
    image:
      'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?q=80&w=800&auto=format&fit=crop',
    tags: ['Mug', 'Ash', 'Cone 6'],
  },
  {
    id: 2,
    name: 'Rust Terracotta Planter',
    description: 'Burnished terracotta with wax resist band.',
    stage: 'Bisque',
    image:
      'https://images.unsplash.com/photo-1519710164239-da123dc03ef4?q=80&w=800&auto=format&fit=crop',
    tags: ['Planter', 'Terracotta', 'Burnished'],
  },
  {
    id: 3,
    name: 'Shino Serving Bowl',
    description: 'Warm shino with carbon trapping along the rim.',
    stage: 'Fired',
    image:
      'https://images.unsplash.com/photo-1607631752190-4b3d6b4f6b95?q=80&w=800&auto=format&fit=crop',
    tags: ['Bowl', 'Shino', 'Cone 10'],
  },
  {
    id: 4,
    name: 'Celadon Tea Cup',
    description: 'Pale green celadon glaze over porcelain body.',
    stage: 'Glazed',
    image:
      'https://images.unsplash.com/photo-1617196036035-3c90c3f0a5a6?q=80&w=800&auto=format&fit=crop',
    tags: ['Cup', 'Porcelain', 'Celadon'],
  },
  {
    id: 5,
    name: 'Speckled Stoneware Plate',
    description: 'Iron flecked clay with clear satin glaze.',
    stage: 'Fired',
    image:
      'https://images.unsplash.com/photo-1601049878309-91d9cbd32d83?q=80&w=800&auto=format&fit=crop',
    tags: ['Plate', 'Stoneware', 'Cone 6'],
  },
  {
    id: 6,
    name: 'Matte Black Vase',
    description: 'Tall vase with black slip and matte glaze finish.',
    stage: 'Trimmed',
    image:
      'https://images.unsplash.com/photo-1622205319241-cf6b3c5744cb?q=80&w=800&auto=format&fit=crop',
    tags: ['Vase', 'Slip', 'Matte'],
  },
  {
    id: 7,
    name: 'Turquoise Bowl',
    description: 'Bright turquoise glaze with carved wave pattern.',
    stage: 'Formed',
    image:
      'https://images.unsplash.com/photo-1606501585512-5a6c7d0c2f17?q=80&w=800&auto=format&fit=crop',
    tags: ['Bowl', 'Turquoise', 'Carved'],
  },
  {
    id: 8,
    name: 'Amber Jar',
    description: 'Wheel-thrown jar with amber glaze and lid.',
    stage: 'Glazed',
    image:
      'https://images.unsplash.com/photo-1565701318169-dc4b46a4dfd7?q=80&w=800&auto=format&fit=crop',
    tags: ['Jar', 'Lidded', 'Amber'],
  },
  {
    id: 9,
    name: 'Marbled Mug',
    description: 'Two-tone clay body marbled together, clear glaze.',
    stage: 'Fired',
    image:
      'https://images.unsplash.com/photo-1615485296734-7cfc9b3806f9?q=80&w=800&auto=format&fit=crop',
    tags: ['Mug', 'Marbled', 'Cone 6'],
  },
  {
    id: 10,
    name: 'Experiment: Soda-Fired Cup',
    description: 'Trial piece for soda firing with flashing slips.',
    stage: 'Bisque',
    image:
      'https://images.unsplash.com/photo-1622205212250-12d8a14bcbbf?q=80&w=800&auto=format&fit=crop',
    tags: ['Cup', 'Experiment', 'Soda Fire'],
  },
]

export const seedLikedIds = [1, 3, 5]

export const seedStats = { formed: 12, trimmed: 8, glazed: 6, fired: 9 }

export const seedActivity = [
  {
    id: 1,
    user: 'Etta',
    action: 'formed',
    target: 'Turquoise Bowl',
    time: 'just now',
    avatar: 'https://i.pravatar.cc/100?img=45',
  },
  {
    id: 2,
    user: 'Millicent',
    action: 'updated',
    target: 'Blue Ash Mug to Glazed',
    time: '2h ago',
    avatar: 'https://i.pravatar.cc/100?img=22',
  },
  {
    id: 3,
    user: 'Roux',
    action: 'fired',
    target: 'Speckled Stoneware Plate',
    time: '5h ago',
    avatar: 'https://i.pravatar.cc/100?img=50',
  },
  {
    id: 4,
    user: 'Milo',
    action: 'trimmed',
    target: 'Rust Terracotta Planter',
    time: 'yesterday',
    avatar: 'https://i.pravatar.cc/100?img=30',
  },
  {
    id: 5,
    user: 'Bix',
    action: 'glazed',
    target: 'Celadon Tea Cup',
    time: '2 days ago',
    avatar: 'https://i.pravatar.cc/100?img=40',
  },
  {
    id: 6,
    user: 'Dart',
    action: 'delivered news about',
    target: 'Experiment: Soda-Fired Cup',
    time: '3 days ago',
    avatar: 'https://i.pravatar.cc/100?img=60',
  },
  {
    id: 7,
    user: 'Raya',
    action: 'added',
    target: 'Marbled Mug',
    time: '4 days ago',
    avatar: 'https://i.pravatar.cc/100?img=20',
  },
  {
    id: 8,
    user: 'Pippin',
    action: 'liked',
    target: 'Amber Jar',
    time: '5 days ago',
    avatar: 'https://i.pravatar.cc/100?img=12',
  },
]
