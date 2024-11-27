import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const ClothingStoreApp());
}

class ClothingStoreApp extends StatelessWidget {
  const ClothingStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Магазин Одежды',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  final int _numIcons = 50; //Кол. элементов на экране
  final List<_IconData> _iconsData = [];
  late AnimationController _controller;
  bool _iconsGenerated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20), //Длительность анимации
      vsync: this,
    )..repeat();

    _controller.addListener(() {
      setState(() {
        _updateIcons();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generateIcons() {
    final random = Random();
    final screenSize = MediaQuery.of(context).size;
    for (int i = 0; i < _numIcons; i++) {
      _iconsData.add(
        _IconData(
          icon: _getRandomIcon(),
          color: _getRandomColor(),
          size: random.nextDouble() * 30 + 20, // Размер от 20 до 50
          position: Offset(
            random.nextDouble() * screenSize.width,
            random.nextDouble() * screenSize.height,
          ),
          direction: Offset(
            random.nextDouble() * 2 - 1,
            random.nextDouble() * 2 - 1,
          ).normalize(),
          speed: random.nextDouble() * 1 + 0.5, // Скорость от 0.5 до 1.5
        ),
      );
    }
  }

  void _updateIcons() {
    final screenSize = MediaQuery.of(context).size;
    for (var iconData in _iconsData) {
      Offset newPosition = iconData.position + iconData.direction * iconData.speed;
      if (newPosition.dx < 0 || newPosition.dx > screenSize.width - iconData.size) {
        iconData.direction = Offset(-iconData.direction.dx, iconData.direction.dy);
      }
      if (newPosition.dy < 0 || newPosition.dy > screenSize.height - iconData.size) {
        iconData.direction = Offset(iconData.direction.dx, -iconData.direction.dy);
      }
      iconData.position += iconData.direction * iconData.speed;
    }
  }

  IconData _getRandomIcon() {
    final icons = [
      Icons.checkroom,
      Icons.shopping_bag,
      Icons.directions_run,
      Icons.watch,
      Icons.style,
      Icons.face,
      Icons.favorite,
      Icons.star,
      Icons.shopping_cart,
    ];
    return icons[Random().nextInt(icons.length)];
  }

  Color _getRandomColor() {
    final colors = [
      Colors.white.withOpacity(0.3),
      Colors.white.withOpacity(0.4),
      Colors.white.withOpacity(0.5),
      Colors.white.withOpacity(0.6),
    ];
    return colors[Random().nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    if (!_iconsGenerated) {
      _generateIcons();
      _iconsGenerated = true;
    }
    return Scaffold(
      body: Stack(
        children: [
          // Фоновый градиент
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Анимированные иконки
          ..._iconsData.map((iconData) {
            return Positioned(
              left: iconData.position.dx,
              top: iconData.position.dy,
              child: Icon(
                iconData.icon,
                color: iconData.color,
                size: iconData.size,
              ),
            );
          }).toList(),
          // Центральный контент
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Добро пожаловать в\nМагазин Одежды',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 60),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blueAccent,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Войти',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconData {
  IconData icon;
  Color color;
  double size;
  Offset position;
  Offset direction;
  double speed;

  _IconData({
    required this.icon,
    required this.color,
    required this.size,
    required this.position,
    required this.direction,
    required this.speed,
  });
}

// Расширение для нормализации Offset
extension OffsetExtension on Offset {
  Offset normalize() {
    final double length = sqrt(dx * dx + dy * dy);
    if (length == 0) return Offset.zero;
    return Offset(dx / length, dy / length);
  }
}



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  List<Product> favoriteProducts = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> _pages() => [
    CategoryPage(
      onAddToFavorites: (product) {
        setState(() {
          if (!favoriteProducts.contains(product)) {
            favoriteProducts.add(product);
          }
        });
      },
    ),
    FavoritesPage(
      favoriteProducts: favoriteProducts,
      onOrder: () {
        // Логика оформления заказа
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Заказ оформлен'),
            content: const Text(
                'Спасибо за заказ! Мы свяжемся с вами в ближайшее время.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ОК'),
              ),
            ],
          ),
        );
        setState(() {
          favoriteProducts.clear();
        });
      },
      onRemoveFromFavorites: (product) {
        setState(() {
          favoriteProducts.remove(product);
        });
      },
    ),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Магазин Одежды'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: _pages()[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Категории',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Избранное',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.teal,
      ),
    );
  }
}

class CategoryPage extends StatelessWidget {
  final Function(Product) onAddToFavorites;

  const CategoryPage({super.key, required this.onAddToFavorites});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {"name": "Футболки", "icon": Icons.checkroom, "color": Colors.pinkAccent},
      {"name": "Брюки", "icon": Icons.shopping_bag, "color": Colors.blueAccent},
      {"name": "Обувь", "icon": Icons.do_not_step, "color": Colors.orange},
      {"name": "Аксессуары", "icon": Icons.watch, "color": Colors.purple},
      {"name": "Куртки", "icon": Icons.boy, "color": Colors.green},
      {"name": "Платья", "icon": Icons.girl, "color": Colors.redAccent},
      {"name": "Шапки", "icon": Icons.face, "color": Colors.amber},
      {"name": "Нижнее белье","icon": Icons.female, "color": Colors.deepPurple},
    ];

    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return Card(
          color: categories[index]["color"] as Color,
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: ListTile(
            leading: Icon(
              categories[index]["icon"] as IconData,
              color: Colors.white,
            ),
            title: Text(
              categories[index]["name"] as String,
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductListPage(
                    category: categories[index]["name"] as String,
                    onAddToFavorites: onAddToFavorites,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class ProductListPage extends StatelessWidget {
  final String category;
  final Function(Product) onAddToFavorites;

  const ProductListPage({
    super.key,
    required this.category,
    required this.onAddToFavorites,
  });

  @override
  Widget build(BuildContext context) {
    final products = _getProductsByCategory(category);

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        backgroundColor: Colors.teal,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.55,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            elevation: 3,
            shadowColor: Colors.tealAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: product.isLocal
                      ? Image.asset(
                    product.imageUrl,
                    fit: BoxFit.cover,
                  )
                      : Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(
                    product.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '${product.price} руб.',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    icon: const Icon(
                      Icons.favorite_border,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      onAddToFavorites(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                          Text('${product.name} добавлен в избранное'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Product> _getProductsByCategory(String category) {
    switch (category) {
      case 'Футболки':
        return [
          Product(
            name: 'Мужская футболка',
            imageUrl: 'assets/images/1.jpg', // Локальное изображение
            price: 1330,
            isLocal: true, // Указываем что фото локальное
          ),
          Product(
            name: 'Мужская футболка',
            imageUrl: 'assets/images/2.jpg',
            price: 1330,
            isLocal: true,
          ),
          Product(
            name: 'Мужская футболка',
            imageUrl: 'assets/images/3.jpg',
            price: 1330,
            isLocal: true,
          ),
          Product(
            name: 'Мужская футболка',
            imageUrl: 'assets/images/4.jpg',
            price: 1330,
            isLocal: true,
          ),
          Product(
            name: 'Женская футболка',
            imageUrl: 'assets/images/5.jpg',
            price: 1850,
            isLocal: true,
          ),
          Product(
            name: 'Женская футболка',
            imageUrl: 'assets/images/6.jpg',
            price: 1435,
            isLocal: true,
          ),
          Product(
            name: 'Женская футболка',
            imageUrl: 'assets/images/7.jpg',
            price: 1850,
            isLocal: true,
          ),
          Product(
            name: 'Женская футболка',
            imageUrl: 'assets/images/8.jpg',
            price: 1850,
            isLocal: true,
          ),
        ];
      case 'Брюки':
        return [
          Product(
            name: 'Мужские брюки',
            imageUrl: 'assets/images/9.jpg',
            price: 2390,
            isLocal: true,
          ),
          Product(
            name: 'Мужские брюки',
            imageUrl: 'assets/images/10.jpg',
            price: 2390,
            isLocal: true,
          ),
          Product(
            name: 'Мужские брюки',
            imageUrl: 'assets/images/11.jpg',
            price: 2055,
            isLocal: true,
          ),
          Product(
            name: 'Мужские брюки',
            imageUrl: 'assets/images/12.jpg',
            price: 2290,
            isLocal: true,
          ),
          Product(
            name: 'Женские брюки',
            imageUrl: 'assets/images/13.jpg',
            price: 2390,
            isLocal: true,
          ),
          Product(
            name: 'Женские брюки',
            imageUrl: 'assets/images/14.jpg',
            price: 2390,
            isLocal: true,
          ),
          Product(
            name: 'Женские брюки',
            imageUrl: 'assets/images/15.jpg',
            price: 2055,
            isLocal: true,
          ),
          Product(
            name: 'Женские брюки',
            imageUrl: 'assets/images/16.jpg',
            price: 2290,
            isLocal: true,
          )
        ];
      case 'Обувь':
        return [
          Product(
            name: 'Мужская обувь',
            imageUrl: 'assets/images/17.jpg',
            price: 2499,
            isLocal: true,
          ),
          Product(
            name: 'Мужская обувь',
            imageUrl: 'assets/images/18.jpg',
            price: 3749,
            isLocal: true,
          ),
          Product(
            name: 'Мужская обувь',
            imageUrl: 'assets/images/19.jpg',
            price: 7999,
            isLocal: true,
          ),
          Product(
            name: 'Мужская обувь',
            imageUrl: 'assets/images/20.jpg',
            price: 5999,
            isLocal: true,
          ),
          Product(
            name: 'Женская обувь',
            imageUrl: 'assets/images/21.jpg',
            price: 9929,
            isLocal: true,
          ),
          Product(
            name: 'Женская обувь',
            imageUrl: 'assets/images/22.jpg',
            price: 2999,
            isLocal: true,
          ),
          Product(
            name: 'Женская обувь',
            imageUrl: 'assets/images/23.jpg',
            price: 1739,
            isLocal: true,
          ),
          Product(
            name: 'Женская обувь',
            imageUrl: 'assets/images/24.jpg',
            price: 5590,
            isLocal: true,
          )
        ];
      case 'Аксессуары':
        return [
          Product(
            name: 'Рюкзак Skechers',
            imageUrl: 'assets/images/25.jpg',
            price: 299,
            isLocal: true,
          ),
          Product(
            name: 'Носки FILA',
            imageUrl: 'assets/images/26.jpg',
            price: 599,
            isLocal: true,
          ),
          Product(
            name: 'Бейсболка PUMA Metal Cat',
            imageUrl: 'assets/images/27.jpg',
            price: 659,
            isLocal: true,
          ),
          Product(
            name: 'Сумка через плечо',
            imageUrl: 'assets/images/28.jpg',
            price: 419,
            isLocal: true,
          )
        ];
      case 'Куртки':
        return [
          Product(
            name: 'Мужская куртка',
            imageUrl: 'assets/images/29.jpg',
            price: 7715,
            isLocal: true,
          ),
          Product(
            name: 'Мужская куртка',
            imageUrl: 'assets/images/30.jpg',
            price: 7485,
            isLocal: true,
          ),
          Product(
            name: 'Мужская куртка',
            imageUrl: 'assets/images/31.jpg',
            price: 7499,
            isLocal: true,
          ),
          Product(
            name: 'Женская куртка',
            imageUrl: 'assets/images/32.jpg',
            price: 5855,
            isLocal: true,
          ),
          Product(
            name: 'Женская куртка',
            imageUrl: 'assets/images/33.jpg',
            price: 5855,
            isLocal: true,
          ),
          Product(
            name: 'Женская куртка',
            imageUrl: 'assets/images/34.jpg',
            price: 5855,
            isLocal: true,
          )
        ];
      case 'Платья':
        return[
          Product(
            name: 'Платье-Футболка "Котическая love"',
            imageUrl: 'assets/images/35.jpg',
            price: 1490,
            isLocal: true,
          ),
          Product(
            name: 'Платье-Худи Тоторо',
            imageUrl: 'assets/images/36.jpg',
            price: 3600,
            isLocal: true,
          ),
          Product(
            name: 'Платье-худи Rat',
            imageUrl: 'assets/images/37.jpg',
            price: 3600,
            isLocal: true,
          ),
          Product(
            name: 'Платье-худи Milka',
            imageUrl: 'assets/images/38.jpg',
            price: 3600,
            isLocal: true,
          )
        ];
      case 'Шапки':
        return[
          Product(
            name: 'Шапка Душнила',
            imageUrl: 'assets/images/39.jpg',
            price: 1230,
            isLocal: true,
          ),
          Product(
            name: 'Шапка с помпоном ЪУЪ',
            imageUrl: 'assets/images/40.jpg',
            price: 1230,
            isLocal: true,
          ),
          Product(
            name: 'Шапка с помпоном Кот',
            imageUrl: 'assets/images/41.jpg',
            price: 1025,
            isLocal: true,
          ),
          Product(
            name: 'Шапка Что-то на китайском',
            imageUrl: 'assets/images/42.jpg',
            price: 610,
            isLocal: true,
          )
        ];
      case 'Нижнее белье':
        return[
          Product(
            name: 'Мужские плавки',
            imageUrl: 'assets/images/43.jpg',
            price: 800,
            isLocal: true,
          ),
          Product(
            name: 'Женское белье',
            imageUrl: 'assets/images/44.jpg',
            price: 950,
            isLocal: true,
          )
        ];

    // Добавьте другие категории и товары
      default:
        return [];
    }
  }
}

class FavoritesPage extends StatelessWidget {
  final List<Product> favoriteProducts;
  final VoidCallback onOrder;
  final Function(Product) onRemoveFromFavorites;

  const FavoritesPage({
    super.key,
    required this.favoriteProducts,
    required this.onOrder,
    required this.onRemoveFromFavorites,
  });

  @override
  Widget build(BuildContext context) {
    double totalPrice =
    favoriteProducts.fold(0, (sum, item) => sum + item.price);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Избранное'),
        backgroundColor: Colors.teal,
      ),
      body: favoriteProducts.isEmpty
          ? const Center(
        child: Text(
          'Ваши избранные товары появятся здесь.',
          style: TextStyle(fontSize: 16),
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: favoriteProducts.length,
              itemBuilder: (context, index) {
                final product = favoriteProducts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  elevation: 2,
                  child: ListTile(
                    leading: product.isLocal
                        ? Image.asset(
                      product.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                        : Image.network(
                      product.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(product.name),
                    subtitle: Text('${product.price} руб.'),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.redAccent,
                      ),
                      onPressed: () {
                        onRemoveFromFavorites(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${product.name} удалён из избранного'),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, -1),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Общая сумма: $totalPrice руб.',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: onOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 80, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Оформить заказ',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Исходник профиля
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Информация о профиле',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 100,
                backgroundImage: AssetImage('assets/images/45.jpg'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Борукулова Элида Марсовна',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              const Text(
                '1304elka@gmail.com',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Логика выхода из профиля
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SplashScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Выйти из профиля',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Product {
  final String name;
  final String imageUrl;
  final double price;
  final bool isLocal;

  Product({
    required this.name,
    required this.imageUrl,
    required this.price,
    this.isLocal = false, // По умолчанию false
  });

  // Переопределение операторов для корректного сравнения объектов
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Product &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              imageUrl == other.imageUrl &&
              price == other.price &&
              isLocal == other.isLocal;

  @override
  int get hashCode =>
      name.hashCode ^ imageUrl.hashCode ^ price.hashCode ^ isLocal.hashCode;
}
