// main.dart
// Shopfront — responsive grid, image-first detail (SliverAppBar),
// dedicated Cart page with quantity controls, desktop-friendly hero height,
// INDIAN PRODUCTS + INDIAN RUPEES (₹) formatting.
// Dependency: google_fonts: ^6.0.0

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const ShopfrontApp());

class ShopfrontApp extends StatefulWidget {
  const ShopfrontApp({super.key});
  @override
  State<ShopfrontApp> createState() => _ShopfrontAppState();
}

class _ShopfrontAppState extends State<ShopfrontApp> {
  ThemeMode _themeMode = ThemeMode.system;
  final CartModel _cart = CartModel();

  void _toggleTheme() => setState(() {
    _themeMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
  });

  @override
  Widget build(BuildContext context) {
    final light = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF4F46E5),
      scaffoldBackgroundColor: const Color(0xFFF7F7FB),
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
    );

    final dark = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF0EA5A4),
      scaffoldBackgroundColor: const Color(0xFF0B0F1A),
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.dark(useMaterial3: true).textTheme,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
    );

    return CartScope(
      cart: _cart,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Shopfront',
        theme: light,
        darkTheme: dark,
        themeMode: _themeMode,
        home: HomePage(themeMode: _themeMode, onToggleTheme: _toggleTheme),
      ),
    );
  }
}

/// ===== Helpers: INR formatting (Indian numbering system) =====
String formatINR(num amount) {
  // formats 149999 -> "1,49,999"
  final s = amount.round().toString();
  if (s.length <= 3) return '₹$s';
  final last3 = s.substring(s.length - 3);
  String rest = s.substring(0, s.length - 3);
  final buf = StringBuffer();
  while (rest.length > 2) {
    buf.write(',${rest.substring(rest.length - 2)}');
    rest = rest.substring(0, rest.length - 2);
  }
  buf.write(',$last3');
  return '₹$rest${buf.toString()}';
}

/// ===== Cart state (items, qty, totals) =====
class CartModel extends ChangeNotifier {
  final Map<String, int> _qty = {}; // id -> quantity
  final Map<String, Product> _products = {for (final p in products) p.id: p};

  int get totalCount => _qty.values.fold(0, (a, b) => a + b);

  double get totalPrice => _qty.entries.fold(0.0, (sum, e) {
    final p = _products[e.key]!;
    return sum + (p.price * e.value);
  });

  Map<Product, int> get items => {
    for (final e in _qty.entries) _products[e.key]!: e.value,
  };

  void add(Product p, {int by = 1}) {
    _qty.update(p.id, (v) => v + by, ifAbsent: () => by);
    notifyListeners();
  }

  void removeOne(Product p) {
    if (!_qty.containsKey(p.id)) return;
    final q = _qty[p.id]! - 1;
    if (q <= 0) {
      _qty.remove(p.id);
    } else {
      _qty[p.id] = q;
    }
    notifyListeners();
  }

  void setQuantity(Product p, int q) {
    if (q <= 0) {
      _qty.remove(p.id);
    } else {
      _qty[p.id] = q;
    }
    notifyListeners();
  }

  void clear() {
    _qty.clear();
    notifyListeners();
  }
}

class CartScope extends InheritedNotifier<CartModel> {
  final CartModel cart;
  const CartScope({super.key, required this.cart, required super.child})
    : super(notifier: cart);

  static CartModel of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CartScope>()!.cart;

  @override
  bool updateShouldNotify(covariant InheritedNotifier oldWidget) => true;
}

/// ===== Products (Indian-flavoured mock catalog) =====
class Product {
  final String id;
  final String name;
  final String category;
  final int price; // INR (e.g., 6499)
  final List<Color> colors;
  final String description;
  final String emoji;
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.colors,
    required this.description,
    required this.emoji,
  });
}

const products = <Product>[
  Product(
    id: 'p1',
    name: 'Nike Air Zoom Pegasus 40',
    category: 'Men • Running Shoes',
    price: 8499,
    colors: [Color(0xFF7C83FD), Color(0xFF96F7D2)],
    description:
        'Iconic Nike Pegasus for daily runs. Responsive cushioning and breathable mesh—perfect for Indian weather.',
    emoji: '👟',
  ),
  Product(
    id: 'p2',
    name: 'Puma Smash v2',
    category: 'Unisex • Sneakers',
    price: 6499,
    colors: [Color(0xFFFFC7A2), Color(0xFFFF8BA5)],
    description:
        'Classic low-profile sneakers from Puma. Clean look that pairs with chinos or denim.',
    emoji: '👟',
  ),
  Product(
    id: 'p3',
    name: 'Bata Oxford',
    category: 'Men • Formal Shoes',
    price: 2899,
    colors: [Color(0xFFBFD7FF), Color(0xFF7C83FD)],
    description:
        'Polished oxfords from Bata—everyday office wear with comfort and durability.',
    emoji: '👞',
  ),
  Product(
    id: 'p4',
    name: 'Woodland Trekker',
    category: 'Men • Boots',
    price: 5299,
    colors: [Color(0xFF96F7D2), Color(0xFF26C6DA)],
    description:
        'Rugged leather boots built for the outdoors. Grippy sole for weekend hikes.',
    emoji: '🥾',
  ),
  Product(
    id: 'p5',
    name: 'boAt Airdopes 141',
    category: 'Audio • TWS Earbuds',
    price: 1999,
    colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
    description:
        'Crystal sound with ENx noise reduction for calls. Made for long commutes.',
    emoji: '🎧',
  ),
  Product(
    id: 'p6',
    name: 'Noise ColorFit Pro 4',
    category: 'Wearables • Smartwatch',
    price: 3499,
    colors: [Color(0xFFB8F1B0), Color(0xFF4DD0E1)],
    description:
        'AMOLED display, health tracking and calls on wrist. Great value daily companion.',
    emoji: '⌚',
  ),
  Product(
    id: 'p7',
    name: 'Wildcraft Laptop Backpack',
    category: 'Bags • 25L',
    price: 2199,
    colors: [Color(0xFFFDD835), Color(0xFFFFA000)],
    description:
        'Tough and light backpack with padded laptop sleeve—ideal for college or work.',
    emoji: '🎒',
  ),
  Product(
    id: 'p8',
    name: 'Fabindia Cotton Kurta',
    category: 'Men • Ethnic Wear',
    price: 1799,
    colors: [Color(0xFFFFE082), Color(0xFFF48FB1)],
    description:
        'Handwoven cotton kurta—breathable, timeless and perfect for festivals.',
    emoji: '👕',
  ),
  Product(
    id: 'p9',
    name: 'Prestige Svachh Cooker 5L',
    category: 'Home & Kitchen',
    price: 2699,
    colors: [Color(0xFFA5D6A7), Color(0xFF66BB6A)],
    description:
        '5L pressure cooker with spill control lid—fast cooking for Indian kitchens.',
    emoji: '🍳',
  ),
  Product(
    id: 'p10',
    name: 'Havells Table Lamp',
    category: 'Lighting',
    price: 1499,
    colors: [Color(0xFFFFD571), Color(0xFFFF8A80)],
    description:
        'Warm ambient light with matte finish—a calm glow for late-night reading.',
    emoji: '💡',
  ),
  Product(
    id: 'p11',
    name: 'Redmi Note 13',
    category: 'Mobiles • 5G',
    price: 14999,
    colors: [Color(0xFF80DEEA), Color(0xFF7C83FD)],
    description:
        'Sharp AMOLED display and long battery life—great value 5G smartphone.',
    emoji: '📱',
  ),
  Product(
    id: 'p12',
    name: 'Adidas India Tee',
    category: 'Unisex • Sportswear',
    price: 1299,
    colors: [Color(0xFF81D4FA), Color(0xFF64B5F6)],
    description:
        'Lightweight performance tee with quick-dry fabric. Train or lounge in style.',
    emoji: '👕',
  ),
];

/// ===== Home (responsive grid) =====
class HomePage extends StatefulWidget {
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;
  const HomePage({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final bodyPad = const EdgeInsets.symmetric(horizontal: 16, vertical: 14);
    final filtered = products
        .where(
          (p) =>
              p.name.toLowerCase().contains(_search.toLowerCase()) ||
              p.category.toLowerCase().contains(_search.toLowerCase()),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: Text(
          'Shopfront',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        actions: [
          IconButton(
            tooltip: widget.themeMode == ThemeMode.dark
                ? 'Light mode'
                : 'Dark mode',
            icon: Icon(
              widget.themeMode == ThemeMode.dark
                  ? Icons.wb_sunny_rounded
                  : Icons.nights_stay_rounded,
            ),
            onPressed: widget.onToggleTheme,
          ),
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: CartButton(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: bodyPad,
              child: Row(
                children: [
                  Expanded(
                    child: _SearchField(
                      value: _search,
                      onChanged: (v) => setState(() => _search = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _FilterButton(onTap: () {}),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: bodyPad,
                child: LayoutBuilder(
                  builder: (context, c) {
                    final w = c.maxWidth;
                    int cols;
                    if (w >= 1600)
                      cols = 6;
                    else if (w >= 1300)
                      cols = 5;
                    else if (w >= 1000)
                      cols = 4;
                    else if (w >= 700)
                      cols = 3;
                    else
                      cols = 2;

                    final ratio = w >= 1000 ? 0.9 : 0.78;

                    return GridView.builder(
                      itemCount: filtered.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: ratio,
                      ),
                      itemBuilder: (_, i) => ProductCard(product: filtered[i]),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===== Cart button with badge and pop animation =====
class CartButton extends StatefulWidget {
  const CartButton({super.key});
  @override
  State<CartButton> createState() => _CartButtonState();
}

class _CartButtonState extends State<CartButton> {
  int _last = 0;

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);
    return AnimatedBuilder(
      animation: cart,
      builder: (context, _) {
        final count = cart.totalCount;
        final changed = count != _last;
        _last = count;
        return TweenAnimationBuilder<double>(
          key: ValueKey(count),
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutBack,
          builder: (context, t, child) {
            final scale = changed ? 1 + 0.08 * t : 1.0;
            final bg = Color.lerp(
              Colors.transparent,
              Theme.of(context).colorScheme.primary.withOpacity(0.18),
              t,
            );
            return Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Transform.scale(
                scale: scale,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CartPage()),
                        );
                      },
                      icon: const Icon(Icons.shopping_bag_rounded),
                      tooltip: 'Cart',
                    ),
                    if (count > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// ===== Search + Filter =====
class _SearchField extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _SearchField({required this.value, required this.onChanged});
  @override
  State<_SearchField> createState() => __SearchFieldState();
}

class __SearchFieldState extends State<_SearchField> {
  late final TextEditingController _c;
  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _c.text = widget.value;
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.onSurface.withOpacity(0.06);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.search_rounded),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _c,
              onChanged: widget.onChanged,
              decoration: const InputDecoration(
                hintText: 'Search products or categories',
                isDense: true,
                border: InputBorder.none,
              ),
            ),
          ),
          if (widget.value.isNotEmpty)
            GestureDetector(
              onTap: () {
                _c.clear();
                widget.onChanged('');
              },
              child: const Icon(Icons.close_rounded, size: 18),
            ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final VoidCallback onTap;
  const _FilterButton({required this.onTap});
  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surfaceVariant;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.tune_rounded),
        ),
      ),
    );
  }
}

/// ===== Product Card =====
class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black.withOpacity(0.04)
                  : Colors.black.withOpacity(0.6),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'image_${product.id}',
              child: _ProductImage(
                product: product,
                size: 120,
                borderRadius: 12,
              ),
            ),
            const SizedBox(height: 12),
            Hero(
              tag: 'title_${product.id}',
              flightShuttleBuilder: _titleFlightBuilder,
              child: Material(
                type: MaterialType.transparency,
                child: Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              product.category,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium!.color!.withOpacity(0.6),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Hero(
                  tag: 'price_${product.id}',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(
                      formatINR(product.price),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => CartScope.of(context).add(product),
                  icon: const Icon(Icons.add_shopping_cart_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _titleFlightBuilder(
    BuildContext _,
    Animation<double> a,
    HeroFlightDirection __,
    BuildContext from,
    BuildContext to,
  ) {
    return ScaleTransition(
      scale: Tween(begin: 0.97, end: 1.0).animate(a),
      child: to.widget,
    );
  }

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 480),
        reverseTransitionDuration: const Duration(milliseconds: 360),
        pageBuilder: (_, anim, __) {
          final curved = CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ProductDetailPage(product: product),
          );
        },
      ),
    );
  }
}

/// ===== Product image (emoji + gradient) =====
class _ProductImage extends StatelessWidget {
  final Product product;
  final double size;
  final double borderRadius;
  const _ProductImage({
    required this.product,
    required this.size,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: product.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -size * 0.18,
            right: -size * 0.18,
            child: Transform.rotate(
              angle: math.pi / 6,
              child: Container(
                width: size * 0.7,
                height: size * 0.7,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Center(
            child: Text(product.emoji, style: TextStyle(fontSize: size * 0.42)),
          ),
        ],
      ),
    );
  }
}

/// ===== DETAIL: image-first (desktop-friendly hero height) =====
class ProductDetailPage extends StatelessWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);
    final w = MediaQuery.of(context).size.width;
    final double heroH = (w * 0.35).clamp(380.0, 520.0);

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
      },
      child: Actions(
        actions: {
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (intent) {
              Navigator.of(context).maybePop();
              return null;
            },
          ),
        },
        child: Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                stretch: true,
                expandedHeight: heroH,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Back',
                ),
                actions: const [
                  Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: CartButton(),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'image_${product.id}',
                    child: _ProductImage(
                      product: product,
                      size: heroH,
                      borderRadius: 0,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Hero(
                              tag: 'title_${product.id}',
                              flightShuttleBuilder: (c, a, d, f, t) =>
                                  ScaleTransition(
                                    scale: CurvedAnimation(
                                      parent: a,
                                      curve: Curves.easeOut,
                                    ),
                                    child: t.widget,
                                  ),
                              child: Material(
                                type: MaterialType.transparency,
                                child: Text(
                                  product.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Hero(
                            tag: 'price_${product.id}',
                            child: Material(
                              type: MaterialType.transparency,
                              child: Text(
                                formatINR(product.price),
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.category,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.color!.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Description',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          height: 1.5,
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.color!.withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                cart.add(product);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${product.name} added to cart',
                                    ),
                                    duration: const Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add_shopping_cart_rounded),
                              label: Text(
                                'Add to Cart',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Saved ${product.name}'),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Icon(Icons.favorite_border_rounded),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===== CART PAGE =====
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);
    return AnimatedBuilder(
      animation: cart,
      builder: (_, __) {
        final entries = cart.items.entries.toList();
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Your Cart',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
            actions: [
              if (entries.isNotEmpty)
                TextButton(onPressed: cart.clear, child: const Text('Clear')),
            ],
          ),
          body: entries.isEmpty
              ? _EmptyCart()
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        itemBuilder: (_, i) {
                          final product = entries[i].key;
                          final qty = entries[i].value;
                          final line = product.price * qty.toDouble();
                          return _CartTile(
                            product: product,
                            qty: qty,
                            onDec: () => cart.removeOne(product),
                            onInc: () => cart.add(product),
                            onDelete: () => cart.setQuantity(product, 0),
                            lineTotal: line,
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemCount: entries.length,
                      ),
                    ),
                    const Divider(height: 1),
                    _CartSummary(total: cart.totalPrice),
                  ],
                ),
        );
      },
    );
  }
}

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 64),
            const SizedBox(height: 12),
            Text(
              'Your cart is empty',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Browse the catalog and add items to your cart.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium!.color!.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continue Shopping'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartTile extends StatelessWidget {
  final Product product;
  final int qty;
  final VoidCallback onDec;
  final VoidCallback onInc;
  final VoidCallback onDelete;
  final double lineTotal;
  const _CartTile({
    required this.product,
    required this.qty,
    required this.onDec,
    required this.onInc,
    required this.onDelete,
    required this.lineTotal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.light
                ? Colors.black.withOpacity(0.04)
                : Colors.black.withOpacity(0.6),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            height: 72,
            child: _ProductImage(product: product, size: 72, borderRadius: 12),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product.category,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: theme.textTheme.bodyMedium!.color!.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formatINR(lineTotal),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _QtyStepper(qty: qty, onDec: onDec, onInc: onInc),
          IconButton(
            tooltip: 'Remove',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final int qty;
  final VoidCallback onDec;
  final VoidCallback onInc;
  const _QtyStepper({
    required this.qty,
    required this.onDec,
    required this.onInc,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _IconBox(icon: Icons.remove_rounded, onTap: onDec),
        Container(
          width: 40,
          height: 36,
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: ShapeDecoration(shape: border),
          child: Text(
            '$qty',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
        ),
        _IconBox(icon: Icons.add_rounded, onTap: onInc),
      ],
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBox({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.onSurface.withOpacity(0.06);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final double total;
  const _CartSummary({required this.total});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Total',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                formatINR(total),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: total <= 0
                  ? null
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Checkout is a mock here ✨'),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
              child: Text(
                'Checkout',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
