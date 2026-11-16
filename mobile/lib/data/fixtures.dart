import 'models.dart';

const washdayCategories = <LaundryCategory>[
  LaundryCategory(
    id: 'shirts',
    name: 'Shirts',
    description: 'Everyday shirts, blouses and light tops, finished neatly.',
    imageAsset: 'assets/images/hero-shirt.jpg',
    services: [
      ServiceOffering(
        id: 'shirts-wash-fold',
        name: 'Wash & fold',
        description: 'Everyday shirts washed, dried and neatly folded.',
        price: 2.00,
        unit: 'kg',
        duration: '6 h',
      ),
      ServiceOffering(
        id: 'shirts-press-only',
        name: 'Press only',
        description: 'Already clean? Returned crisp on a hanger.',
        price: 3.50,
        unit: 'item',
        duration: '24 h',
      ),
      ServiceOffering(
        id: 'shirts-express',
        name: 'Express wash',
        description: 'Priority wash for same-day pickup.',
        price: 4.00,
        unit: 'kg',
        duration: '3 h',
      ),
    ],
  ),
  LaundryCategory(
    id: 'pants',
    name: 'Pants',
    description: 'Trousers, jeans and casual bottoms, washed and folded.',
    imageAsset: 'assets/images/category-pants.jpg',
    services: [
      ServiceOffering(
        id: 'pants-wash-fold',
        name: 'Wash & fold',
        description: 'Trousers and jeans washed, dried and folded.',
        price: 2.00,
        unit: 'kg',
        duration: '6 h',
      ),
      ServiceOffering(
        id: 'pants-press-only',
        name: 'Press only',
        description: 'Neatly pressed with a sharp centre crease.',
        price: 3.00,
        unit: 'item',
        duration: '24 h',
      ),
      ServiceOffering(
        id: 'pants-express',
        name: 'Express wash',
        description: 'Fast turnaround for a favourite pair.',
        price: 4.00,
        unit: 'kg',
        duration: '3 h',
      ),
    ],
  ),
  LaundryCategory(
    id: 'dresses',
    name: 'Dresses',
    description:
        'Dresses, skirts and delicate pieces that need a gentler clean.',
    imageAsset: 'assets/images/category-dresses.jpg',
    services: [
      ServiceOffering(
        id: 'dresses-dry-clean',
        name: 'Dry clean',
        description: 'Gentle solvent clean for structured or delicate dresses.',
        price: 8.00,
        unit: 'item',
        duration: '48 h',
      ),
      ServiceOffering(
        id: 'dresses-gentle-wash',
        name: 'Gentle wash',
        description: 'Low-heat wash for everyday dresses and skirts.',
        price: 3.00,
        unit: 'kg',
        duration: '24 h',
      ),
      ServiceOffering(
        id: 'dresses-press-only',
        name: 'Press only',
        description: 'Light pressing for a smooth finish.',
        price: 4.00,
        unit: 'item',
        duration: '24 h',
      ),
    ],
  ),
  LaundryCategory(
    id: 'bedding',
    name: 'Bedding',
    description: 'Sheets, duvet covers and household linen for a fresh reset.',
    imageAsset: 'assets/images/category-bedding.jpg',
    services: [
      ServiceOffering(
        id: 'bedding-wash-fold',
        name: 'Wash & fold',
        description: 'Sheets and cases washed, dried and folded.',
        price: 2.50,
        unit: 'kg',
        duration: '6 h',
      ),
      ServiceOffering(
        id: 'bedding-duvet',
        name: 'Duvet clean',
        description: 'A deep, gentle clean for duvets and thick covers.',
        price: 9.00,
        unit: 'item',
        duration: '24 h',
      ),
      ServiceOffering(
        id: 'bedding-express',
        name: 'Express wash',
        description: 'Fresh bedding back the same day.',
        price: 4.50,
        unit: 'kg',
        duration: '3 h',
      ),
    ],
  ),
];

LaundryCategory? categoryById(String? id) {
  if (id == null) return null;
  for (final category in washdayCategories) {
    if (category.id == id) return category;
  }
  return null;
}

ServiceOffering? serviceById(String? id) {
  if (id == null) return null;
  for (final category in washdayCategories) {
    for (final service in category.services) {
      if (service.id == id) return service;
    }
  }
  return null;
}

const welcomeVoucher = VoucherOffer(
  code: 'WELCOME10',
  discount: '10% off',
  minimumSpend: 3.00,
  cap: 5.00,
  description: '10% off your first wash & fold order.',
);

const clerkMetrics = <DashboardMetric>[
  DashboardMetric(label: 'Orders today', value: '12', note: '6 still open'),
  DashboardMetric(
    label: 'Ready for pickup',
    value: '4',
    note: '2 since yesterday',
  ),
  DashboardMetric(label: 'In progress', value: '2', note: 'Wash and press'),
  DashboardMetric(
    label: 'Sales today',
    value: '184.50',
    note: 'Cash and transfer',
  ),
];

const ownerMetrics = <DashboardMetric>[
  DashboardMetric(
    label: 'Sales today',
    value: '412.80',
    note: 'Cash and transfer',
  ),
  DashboardMetric(label: 'Orders today', value: '22', note: '6 still open'),
  DashboardMetric(
    label: 'Average order',
    value: '18.76',
    note: 'Per paid order',
  ),
  DashboardMetric(
    label: 'Ready > 2 days',
    value: '2',
    note: 'Pickup follow-up',
  ),
];

const clerkQueueLoad = <QueueLoad>[
  QueueLoad(label: 'Ready', count: 4, max: 6, tone: 'amber'),
  QueueLoad(label: 'Processing', count: 2, max: 6, tone: 'teal'),
  QueueLoad(label: 'Unpaid', count: 3, max: 6, tone: 'red'),
];

const weekSales = <(String, double)>[
  ('Mon', 284),
  ('Tue', 336),
  ('Wed', 310),
  ('Thu', 402),
  ('Fri', 388),
  ('Sat', 442),
  ('Sun', 413),
];

const ownerServiceMix = <(String, int)>[
  ('Wash & fold', 38),
  ('Bedding', 24),
  ('Press', 22),
  ('Dry clean', 16),
];
