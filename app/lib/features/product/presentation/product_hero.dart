/// Hero tag for a product image. [scope] (e.g. the Home section id) keeps
/// tags unique when the same product appears in several sections.
String productHeroTag(String productId, {String? scope}) =>
    'product-image-${scope ?? 'detail'}-$productId';
