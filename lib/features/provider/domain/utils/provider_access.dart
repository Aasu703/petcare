typedef ProviderType = String?;

String _normalizeProviderType(ProviderType providerType) {
  return (providerType ?? '').trim().toLowerCase();
}

bool isVetProvider(ProviderType providerType) =>
    _normalizeProviderType(providerType) == 'vet';

bool isShopProvider(ProviderType providerType) =>
    _normalizeProviderType(providerType) == 'shop';

bool isGroomerProvider(ProviderType providerType) =>
    _normalizeProviderType(providerType) == 'babysitter';

bool canManageServices(ProviderType providerType) =>
    isVetProvider(providerType) || isGroomerProvider(providerType);

bool canManageBookings(ProviderType providerType) =>
    canManageServices(providerType);

bool canManageInventory(ProviderType providerType) =>
    isShopProvider(providerType);

bool canAccessVetFeatures(ProviderType providerType) =>
    isVetProvider(providerType);

String getProviderTypeLabel(ProviderType providerType) {
  if (isVetProvider(providerType)) return 'Vet';
  if (isShopProvider(providerType)) return 'Shop Owner';
  if (isGroomerProvider(providerType)) return 'Groomer';
  return 'Provider';
}
