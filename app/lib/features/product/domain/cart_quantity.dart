/// Quantity rules for Product detail. Starts at 0: the first + reveals the
/// Add to cart bar (see DECISIONS.md); once revealed the minimum is 1.
abstract final class CartQuantity {
  static const int initial = 0;
  static const int max = 99;

  static int increment(int quantity) => quantity >= max ? max : quantity + 1;

  static int decrement(int quantity) => quantity <= 0 ? 0 : quantity - 1;

  static int lineTotal(int quantity, int unitPriceMmk) =>
      quantity * unitPriceMmk;
}
