
import 'package:flutter/material.dart';

void main() {
  runApp(const FakhriQuranApp());
}

const Color primaryColor = Color(0xFF087F68);

const List<String> surahs = [
  'الفاتحة', 'البقرة', 'آل عمران', 'النساء', 'المائدة',
  'الأنعام', 'الأعراف', 'الأنفال', 'التوبة', 'يونس',
  'هود', 'يوسف', 'الرعد', 'إبراهيم', 'الحجر',
  'النحل', 'الإسراء', 'الكهف', 'مريم', 'طه',
  'الأنبياء', 'الحج', 'المؤمنون', 'النور', 'الفرقان',
  'الشعراء', 'النمل', 'القصص', 'العنكبوت', 'الروم',
  'لقمان', 'السجدة', 'الأحزاب', 'سبأ', 'فاطر',
  'يس', 'الصافات', 'ص', 'الزمر', 'غافر',
  'فصلت', 'الشورى', 'الزخرف', 'الدخان', 'الجاثية',
  'الأحقاف', 'محمد', 'الفتح', 'الحجرات', 'ق',
  'الذاريات', 'الطور', 'النجم', 'القمر', 'الرحمن',
  'الواقعة', 'الحديد', 'المجادلة', 'الحشر', 'الممتحنة',
  'الصف', 'الجمعة', 'المنافقون', 'التغابن', 'الطلاق',
  'التحريم', 'الملك', 'القلم', 'الحاقة', 'المعارج',
  'نوح', 'الجن', 'المزمل', 'المدثر', 'القيامة',
  'الإنسان', 'المرسلات', 'النبأ', 'النازعات', 'عبس',
  'التكوير', 'الانفطار', 'المطففين', 'الانشقاق', 'البروج',
  'الطارق', 'الأعلى', 'الغاشية', 'الفجر', 'البلد',
  'الشمس', 'الليل', 'الضحى', 'الشرح', 'التين',
  'العلق', 'القدر', 'البينة', 'الزلزلة', 'العاديات',
  'القارعة', 'التكاثر', 'العصر', 'الهمزة', 'الفيل',
  'قريش', 'الماعون', 'الكوثر', 'الكافرون', 'النصر',
  'المسد', 'الإخلاص', 'الفلق', 'الناس'
];

class FakhriQuranApp extends StatelessWidget {
  const FakhriQuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fakhri Quran',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8F4),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedTab = 0;
  double fontSize = 24;
  String search = '';
  final Set<int> favorites = {};
  int? lastRead;

  @override
  Widget build(BuildContext context) {
    final pages = [
      buildHome(),
      buildSurahList(),
      buildFavorites(),
      buildTools(),
      buildSettings(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'فخري قرآن',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'بحث',
            icon: const Icon(Icons.search),
            onPressed: () => setState(() => selectedTab = 1),
          ),
        ],
      ),
      body: IndexedStack(
        index: selectedTab,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (index) {
          setState(() => selectedTab = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'القرآن',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'المفضلة',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'الأدوات',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }

  Widget buildHome() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF087F68), Color(0xFF064E45)],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  height: 1.8,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'رفيقك في تلاوة القرآن الكريم',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'تابع قراءتك',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFE0F2EB),
              child: Icon(Icons.menu_book, color: primaryColor),
            ),
            title: Text(
              lastRead == null ? 'ابدأ قراءة القرآن' : 'متابعة القراءة',
            ),
            subtitle: Text(
              lastRead == null
                  ? 'اختر سورة للبدء'
                  : 'سورة ${surahs[lastRead!]}',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => setState(() => selectedTab = 1),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'الوصول السريع',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            quickCard(
              'قائمة السور',
              Icons.menu_book,
              () => setState(() => selectedTab = 1),
            ),
            quickCard(
              'الأذكار',
              Icons.spa,
              () => setState(() => selectedTab = 3),
            ),
            quickCard(
              'المفضلة',
              Icons.bookmark,
              () => setState(() => selectedTab = 2),
            ),
            quickCard(
              'الإعدادات',
              Icons.settings,
              () => setState(() => selectedTab = 4),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'تنبيه: يلزم إضافة نص المصحف الموثوق والتلاوات قبل اعتماد التطبيق للقراءة الفعلية.',
          style: TextStyle(color: Colors.black54, height: 1.6),
        ),
      ],
    );
  }

  Widget quickCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: primaryColor),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget buildSurahList() {
    final results = List.generate(surahs.length, (i) => i)
        .where((i) => surahs[i].contains(search.trim()))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'ابحث عن سورة...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) => setState(() => search = value),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final surahIndex = results[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFE0F2EB),
                    child: Text('${surahIndex + 1}'),
                  ),
                  title: Text(
                    surahs[surahIndex],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('السورة رقم ${surahIndex + 1}'),
                  trailing: IconButton(
                    icon: Icon(
                      favorites.contains(surahIndex)
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: primaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        if (!favorites.add(surahIndex)) {
                          favorites.remove(surahIndex);
                        }
                      });
                    },
                  ),
                  onTap: () {
                    setState(() => lastRead = surahIndex);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SurahScreen(
                          name: surahs[surahIndex],
                          number: surahIndex + 1,
                          fontSize: fontSize,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildFavorites() {
    final items = favorites.toList()..sort();

    if (items.isEmpty) {
      return const Center(
        child: Text('لم تضف أي سورة للمفضلة حتى الآن'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: items.map((index) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.bookmark, color: primaryColor),
            title: Text(surahs[index]),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => setState(() => favorites.remove(index)),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SurahScreen(
                  name: surahs[index],
                  number: index + 1,
                  fontSize: fontSize,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildTools() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'الأذكار والأدوات',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.spa, color: primaryColor),
            title: const Text('الأذكار'),
            subtitle: const Text('أذكار الصباح والمساء'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdhkarScreen()),
            ),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.access_time, color: primaryColor),
            title: Text('مواقيت الصلاة'),
            subtitle: Text('تحتاج إلى إعداد الموقع وطريقة الحساب'),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.explore, color: primaryColor),
            title: Text('القبلة'),
            subtitle: Text('تحتاج إلى بوصلة ومستشعرات الجهاز'),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.video_library, color: primaryColor),
            title: Text('استوديو فيديو الآيات'),
            subtitle: Text('ميزة تحتاج إلى تنفيذ وتصدير فيديو فعلي'),
          ),
        ),
      ],
    );
  }

  Widget buildSettings() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'إعدادات القراءة',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Text('حجم الخط: ${fontSize.round()}'),
        Slider(
          value: fontSize,
          min: 18,
          max: 40,
          divisions: 11,
          label: fontSize.round().toString(),
          onChanged: (value) => setState(() => fontSize = value),
        ),
        const Divider(),
        const ListTile(
          leading: Icon(Icons.language),
          title: Text('اللغة'),
          subtitle: Text('العربية'),
        ),
        const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('عن التطبيق'),
          subtitle: Text('Fakhri Quran'),
        ),
      ],
    );
  }
}

class SurahScreen extends StatelessWidget {
  final String name;
  final int number;
  final double fontSize;

  const SurahScreen({
    super.key,
    required this.name,
    required this.number,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('سورة $name')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.menu_book, size: 64, color: primaryColor),
              const SizedBox(height: 20),
              Text(
                'سورة $name',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'رقم السورة: $number',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                'سيظهر نص السورة هنا بعد ربط التطبيق ببيانات قرآن موثوقة ومراجعة.',
                textAlign: TextAlign.center,
                style: TextStyle(height: 1.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdhkarScreen extends StatefulWidget {
  const AdhkarScreen({super.key});

  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('السبحة الإلكترونية')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'عدد التسبيحات',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 54,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => setState(() => count++),
              icon: const Icon(Icons.add),
              label: const Text('تسبيحة جديدة'),
            ),
            TextButton(
              onPressed: () => setState(() => count = 0),
              child: const Text('تصفير العداد'),
            ),
          ],
        ),
      ),
    );
  }
}
