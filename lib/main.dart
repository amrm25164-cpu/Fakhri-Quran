
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';

const green = Color(0xFF075E54);
const gold = Color(0xFFD8B56D);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FakhriQuranApp());
}

const surahs = <String>[
  'الفاتحة','البقرة','آل عمران','النساء','المائدة','الأنعام',
  'الأعراف','الأنفال','التوبة','يونس','هود','يوسف','الرعد',
  'إبراهيم','الحجر','النحل','الإسراء','الكهف','مريم','طه',
  'الأنبياء','الحج','المؤمنون','النور','الفرقان','الشعراء',
  'النمل','القصص','العنكبوت','الروم','لقمان','السجدة',
  'الأحزاب','سبأ','فاطر','يس','الصافات','ص','الزمر','غافر',
  'فصلت','الشورى','الزخرف','الدخان','الجاثية','الأحقاف',
  'محمد','الفتح','الحجرات','ق','الذاريات','الطور','النجم',
  'القمر','الرحمن','الواقعة','الحديد','المجادلة','الحشر',
  'الممتحنة','الصف','الجمعة','المنافقون','التغابن','الطلاق',
  'التحريم','الملك','القلم','الحاقة','المعارج','نوح','الجن',
  'المزمل','المدثر','القيامة','الإنسان','المرسلات','النبأ',
  'النازعات','عبس','التكوير','الانفطار','المطففين','الانشقاق',
  'البروج','الطارق','الأعلى','الغاشية','الفجر','البلد','الشمس',
  'الليل','الضحى','الشرح','التين','العلق','القدر','البينة',
  'الزلزلة','العاديات','القارعة','التكاثر','العصر','الهمزة',
  'الفيل','قريش','الماعون','الكوثر','الكافرون','النصر',
  'المسد','الإخلاص','الفلق','الناس'
];

class Store {
  static Future<SharedPreferences> get prefs =>
      SharedPreferences.getInstance();

  static Future<void> saveString(String key, String value) async {
    await (await prefs).setString(key, value);
  }

  static Future<void> saveInt(String key, int value) async {
    await (await prefs).setInt(key, value);
  }

  static Future<void> saveDouble(String key, double value) async {
    await (await prefs).setDouble(key, value);
  }

  static Future<void> saveList(String key, List<String> value) async {
    await (await prefs).setStringList(key, value);
  }
}

class FakhriQuranApp extends StatefulWidget {
  const FakhriQuranApp({super.key});

  @override
  State<FakhriQuranApp> createState() => _FakhriQuranAppState();
}

class _FakhriQuranAppState extends State<FakhriQuranApp> {
  bool dark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fakhri Quran',
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: green),
        scaffoldBackgroundColor: const Color(0xFFF7F5EF),
        appBarTheme: const AppBarTheme(
          backgroundColor: green,
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: green,
          brightness: Brightness.dark,
        ),
      ),
      home: MainPage(
        dark: dark,
        onDarkChanged: (value) => setState(() => dark = value),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  final bool dark;
  final ValueChanged<bool> onDarkChanged;

  const MainPage({
    super.key,
    required this.dark,
    required this.onDarkChanged,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int tab = 0;
  int tasbeeh = 0;
  double fontSize = 27;
  String lastRead = 'لم تبدأ القراءة بعد';
  Set<String> favorites = {};
  Set<String> completedAdhkar = {};
  List<String> hifzPlan = [];

  @override
  void initState() {
    super.initState();
    loadState();
  }

  Future<void> loadState() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      tasbeeh = p.getInt('tasbeeh') ?? 0;
      fontSize = p.getDouble('fontSize') ?? 27;
      lastRead = p.getString('lastRead') ?? 'لم تبدأ القراءة بعد';
      favorites = (p.getStringList('favorites') ?? []).toSet();
      completedAdhkar =
          (p.getStringList('completedAdhkar') ?? []).toSet();
      hifzPlan = p.getStringList('hifzPlan') ?? [];
    });
  }

  Future<void> toggleFavorite(String key) async {
    setState(() {
      if (favorites.contains(key)) {
        favorites.remove(key);
      } else {
        favorites.add(key);
      }
    });
    await Store.saveList('favorites', favorites.toList());
  }

  Future<void> updateLastRead(String value) async {
    setState(() => lastRead = value);
    await Store.saveString('lastRead', value);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      QuranTab(
        fontSize: fontSize,
        lastRead: lastRead,
        favorites: favorites,
        onFavorite: toggleFavorite,
        onLastRead: updateLastRead,
      ),
      TasbeehTab(
        count: tasbeeh,
        onChanged: (v) async {
          setState(() => tasbeeh = v);
          await Store.saveInt('tasbeeh', v);
        },
      ),
      const PrayerTab(),
      AdhkarTab(
        completed: completedAdhkar,
        onChanged: (items) async {
          setState(() => completedAdhkar = items);
          await Store.saveList('completedAdhkar', items.toList());
        },
      ),
      HifzTab(
        plan: hifzPlan,
        onChanged: (items) async {
          setState(() => hifzPlan = items);
          await Store.saveList('hifzPlan', items);
        },
      ),
      const AudioTab(),
      const VideoTab(),
      SettingsTab(
        fontSize: fontSize,
        dark: widget.dark,
        onFontChanged: (value) async {
          setState(() => fontSize = value);
          await Store.saveDouble('fontSize', value);
        },
        onDarkChanged: widget.onDarkChanged,
      ),
    ];

    const labels = [
      'القرآن','السبحة','الصلاة','الأذكار',
      'الحفظ','التلاوة','الفيديو','الإعدادات'
    ];

    const icons = [
      Icons.menu_book,
      Icons.radio_button_checked,
      Icons.access_time,
      Icons.favorite_outline,
      Icons.school_outlined,
      Icons.headphones,
      Icons.movie_outlined,
      Icons.settings_outlined,
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'فخري قرآن',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.auto_awesome, color: gold),
            ),
          ],
        ),
        body: IndexedStack(index: tab, children: pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (i) => setState(() => tab = i),
          destinations: List.generate(
            labels.length,
            (i) => NavigationDestination(
              icon: Icon(icons[i]),
              label: labels[i],
            ),
          ),
        ),
      ),
    );
  }
}

class QuranTab extends StatefulWidget {
  final double fontSize;
  final String lastRead;
  final Set<String> favorites;
  final Future<void> Function(String) onFavorite;
  final Future<void> Function(String) onLastRead;

  const QuranTab({
    super.key,
    required this.fontSize,
    required this.lastRead,
    required this.favorites,
    required this.onFavorite,
    required this.onLastRead,
  });

  @override
  State<QuranTab> createState() => _QuranTabState();
}

class _QuranTabState extends State<QuranTab> {
  String search = '';
  bool showFavorites = false;

  @override
  Widget build(BuildContext context) {
    final indexes = List.generate(surahs.length, (i) => i)
        .where((i) =>
            surahs[i].contains(search) ||
            '${i + 1}'.contains(search))
        .where((i) => !showFavorites ||
            widget.favorites.any((f) => f.startsWith('${i + 1}:')))
        .toList();

    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(14),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [green, Color(0xFF138577)],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'وَرَتِّلِ الْقُرْآنَ تَرْتِيلًا',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'آخر قراءة: ${widget.lastRead}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: TextField(
            onChanged: (v) => setState(() => search = v.trim()),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'ابحث عن سورة أو رقمها',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('عرض السور التي لها آيات مفضلة فقط'),
          value: showFavorites,
          onChanged: (v) => setState(() => showFavorites = v),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: indexes.length,
            itemBuilder: (context, i) {
              final index = indexes[i];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(surahs[index]),
                  subtitle: Text('السورة رقم ${index + 1}'),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReaderPage(
                          id: index + 1,
                          name: surahs[index],
                          fontSize: widget.fontSize,
                          favorites: widget.favorites,
                          onFavorite: widget.onFavorite,
                          onLastRead: widget.onLastRead,
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
}

class ReaderPage extends StatefulWidget {
  final int id;
  final String name;
  final double fontSize;
  final Set<String> favorites;
  final Future<void> Function(String) onFavorite;
  final Future<void> Function(String) onLastRead;

  const ReaderPage({
    super.key,
    required this.id,
    required this.name,
    required this.fontSize,
    required this.favorites,
    required this.onFavorite,
    required this.onLastRead,
  });

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  bool loading = true;
  String? error;
  List<dynamic> verses = [];

  @override
  void initState() {
    super.initState();
    loadVerses();
  }

  Future<void> loadVerses() async {
    try {
      final uri = Uri.https(
        'api.quran.com',
        '/api/v4/verses/by_chapter/${widget.id}',
        {
          'language': 'ar',
          'fields': 'text_uthmani',
          'per_page': '300',
        },
      );

      final response = await http.get(uri).timeout(
        const Duration(seconds: 25),
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      if (!mounted) return;

      setState(() {
        verses = data['verses'] as List<dynamic>;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'فشل تحميل الآيات. تحقق من اتصال الإنترنت.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('سورة ${widget.name}')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(error!),
                      FilledButton(
                        onPressed: () {
                          setState(() {
                            loading = true;
                            error = null;
                          });
                          loadVerses();
                        },
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(14),
                  children: [
                    if (widget.id != 1 && widget.id != 9)
                      const Padding(
                        padding: EdgeInsets.all(14),
                        child: Text(
                          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            color: green,
                            height: 2,
                          ),
                        ),
                      ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 7,
                          runSpacing: 12,
                          children: verses.map((verse) {
                            final key = verse['verse_key'].toString();
                            final text =
                                verse['text_uthmani']?.toString() ?? '';

                            return InkWell(
                              onTap: () async {
                                await widget.onLastRead(
                                  '${widget.name}، الآية ${key.split(':').last}',
                                );

                                if (!mounted) return;

                                showModalBottomSheet(
                                  context: context,
                                  builder: (sheetContext) => SafeArea(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            text,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: widget.fontSize,
                                              height: 2,
                                            ),
                                          ),
                                          const SizedBox(height: 18),
                                          FilledButton.icon(
                                            onPressed: () async {
                                              await widget.onFavorite(key);
                                              if (sheetContext.mounted) {
                                                Navigator.pop(sheetContext);
                                              }
                                            },
                                            icon: Icon(
                                              widget.favorites.contains(key)
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                            ),
                                            label: Text(
                                              widget.favorites.contains(key)
                                                  ? 'إزالة من المفضلة'
                                                  : 'إضافة للمفضلة',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                '$text ۞ ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: widget.fontSize,
                                  height: 2.1,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class TasbeehTab extends StatelessWidget {
  final int count;
  final ValueChanged<int> onChanged;

  const TasbeehTab({
    super.key,
    required this.count,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.radio_button_checked, size: 64, color: green),
          const SizedBox(height: 12),
          const Text(
            'السبحة الإلكترونية',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text('سبحان الله', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => onChanged(count + 1),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 35, vertical: 14),
              child: Text('تسبيح', style: TextStyle(fontSize: 20)),
            ),
          ),
          TextButton(
            onPressed: () => onChanged(0),
            child: const Text('تصفير العداد'),
          ),
        ],
      ),
    );
  }
}

class PrayerTab extends StatefulWidget {
  const PrayerTab({super.key});

  @override
  State<PrayerTab> createState() => _PrayerTabState();
}

class _PrayerTabState extends State<PrayerTab> {
  final city = TextEditingController(text: 'Shibin El Kom');
  final country = TextEditingController(text: 'Egypt');
  Map<String, dynamic>? times;
  bool loading = false;
  String? error;

  Future<void> loadTimes() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final uri = Uri.https(
        'api.aladhan.com',
        '/v1/timingsByCity',
        {
          'city': city.text.trim(),
          'country': country.text.trim(),
          'method': '5',
        },
      );

      final response = await http.get(uri).timeout(
        const Duration(seconds: 20),
      );
      final data = jsonDecode(response.body);

      if (data['code'] != 200) throw Exception();

      setState(() {
        times = Map<String, dynamic>.from(data['data']['timings']);
        loading = false;
      });
    } catch (_) {
      setState(() {
        loading = false;
        error = 'تعذر تحميل المواقيت. تحقق من الإنترنت واسم المدينة.';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadTimes();
  }

  @override
  Widget build(BuildContext context) {
    const names = {
      'Fajr': 'الفجر',
      'Sunrise': 'الشروق',
      'Dhuhr': 'الظهر',
      'Asr': 'العصر',
      'Maghrib': 'المغرب',
      'Isha': 'العشاء',
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'مواقيت الصلاة',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        TextField(
          controller: city,
          decoration: const InputDecoration(labelText: 'المدينة'),
        ),
        TextField(
          controller: country,
          decoration: const InputDecoration(labelText: 'الدولة'),
        ),
        const SizedBox(height: 10),
        FilledButton(
          onPressed: loading ? null : loadTimes,
          child: const Text('تحديث المواقيت'),
        ),
        if (loading)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (error != null) Text(error!),
        if (times != null)
          ...names.entries.map(
            (entry) => Card(
              child: ListTile(
                leading: const Icon(Icons.access_time, color: green),
                title: Text(entry.value),
                trailing: Text(
                  '${times![entry.key] ?? '--:--'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class AdhkarTab extends StatelessWidget {
  final Set<String> completed;
  final ValueChanged<Set<String>> onChanged;

  const AdhkarTab({
    super.key,
    required this.completed,
    required this.onChanged,
  });

  static const adhkar = [
    'سبحان الله وبحمده',
    'أستغفر الله وأتوب إليه',
    'لا إله إلا الله وحده لا شريك له',
    'سبحان الله والحمد لله ولا إله إلا الله والله أكبر',
    'اللهم صل وسلم على نبينا محمد',
    'لا حول ولا قوة إلا بالله',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text(
            'الأذكار',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),
        ...adhkar.map((item) {
          final checked = completed.contains(item);

          return Card(
            child: CheckboxListTile(
              value: checked,
              title: Text(item),
              subtitle: Text(checked ? 'تم' : 'اضغط لتحديد الذكر'),
              onChanged: (value) {
                final next = Set<String>.from(completed);
                if (value == true) {
                  next.add(item);
                } else {
                  next.remove(item);
                }
                onChanged(next);
              },
            ),
          );
        }),
        TextButton(
          onPressed: () => onChanged(<String>{}),
          child: const Text('إعادة تعيين القائمة'),
        ),
      ],
    );
  }
}

class HifzTab extends StatelessWidget {
  final List<String> plan;
  final ValueChanged<List<String>> onChanged;

  const HifzTab({
    super.key,
    required this.plan,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'خطة حفظ القرآن',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('أضف هدفًا للحفظ أو المراجعة وحدد ما أنجزته.'),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () async {
              final controller = TextEditingController();
              final result = await showDialog<String>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('إضافة هدف'),
                  content: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'مثال: حفظ أول 5 آيات من الملك',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('إلغاء'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(
                        dialogContext,
                        controller.text.trim(),
                      ),
                      child: const Text('إضافة'),
                    ),
                  ],
                ),
              );

              if (result != null && result.isNotEmpty) {
                onChanged([...plan, '0|$result']);
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('إضافة هدف'),
          ),
          ...plan.asMap().entries.map((entry) {
            final parts = entry.value.split('|');
            final done = parts.length > 1 && parts.first == '1';
            final title = parts.length > 1
                ? parts.sublist(1).join('|')
                : entry.value;

            return Card(
              child: CheckboxListTile(
                value: done,
                title: Text(title),
                onChanged: (value) {
                  final next = List<String>.from(plan);
                  next[entry.key] = '${value == true ? 1 : 0}|$title';
                  onChanged(next);
                },
                secondary: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    final next = List<String>.from(plan)..removeAt(entry.key);
                    onChanged(next);
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class AudioTab extends StatefulWidget {
  const AudioTab({super.key});

  @override
  State<AudioTab> createState() => _AudioTabState();
}

class _AudioTabState extends State<AudioTab> {
  final urlController = TextEditingController();
  final player = AudioPlayer();
  bool loading = false;
  String message = 'أدخل رابط ملف صوتي مباشر يدعم التشغيل.';

  Future<void> play() async {
    final url = urlController.text.trim();
    if (!url.startsWith('https://') && !url.startsWith('http://')) {
      setState(() => message = 'أدخل رابطًا صحيحًا يبدأ بـ http أو https.');
      return;
    }

    setState(() {
      loading = true;
      message = 'جارٍ تجهيز الصوت...';
    });

    try {
      await player.setUrl(url);
      await player.play();
      if (!mounted) return;
      setState(() {
        loading = false;
        message = 'يتم تشغيل التلاوة.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        message = 'تعذر تشغيل الرابط. تأكد أنه رابط صوت مباشر.';
      });
    }
  }

  @override
  void dispose() {
    player.dispose();
    urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'مشغل التلاوة',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: urlController,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: 'رابط ملف الصوت',
            hintText: 'https://example.com/audio.mp3',
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: loading ? null : play,
          child: const Text('تشغيل التلاوة'),
        ),
        OutlinedButton(
          onPressed: () async {
            await player.pause();
            if (mounted) setState(() => message = 'تم إيقاف التشغيل مؤقتًا.');
          },
          child: const Text('إيقاف مؤقت'),
        ),
        OutlinedButton(
          onPressed: () async {
            await player.stop();
            if (mounted) setState(() => message = 'تم إيقاف التلاوة.');
          },
          child: const Text('إيقاف'),
        ),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        const Text(
          'هذه نسخة تشغيل عبر رابط مباشر. قائمة القراء والتنزيل والتشغيل بالخلفية تحتاج إعدادًا إضافيًا.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class VideoTab extends StatefulWidget {
  const VideoTab({super.key});

  @override
  State<VideoTab> createState() => _VideoTabState();
}

class _VideoTabState extends State<VideoTab> {
  final verse = TextEditingController(
    text: 'وَهُوَ مَعَكُمْ أَيْنَ مَا كُنْتُمْ',
  );
  final surah = TextEditingController(text: 'سورة الحديد');
  final reciter = TextEditingController(text: 'اسم القارئ');
  double size = 27;
  int backgroundIndex = 0;

  final backgrounds = const [
    Color(0xFF082F2A),
    Color(0xFF172554),
    Color(0xFF292524),
    Color(0xFF3F1D38),
  ];

  @override
  void dispose() {
    verse.dispose();
    surah.dispose();
    reciter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'استوديو فيديو الآيات',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        AspectRatio(
          aspectRatio: 9 / 16,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: backgrounds[backgroundIndex],
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: gold, width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome, color: gold, size: 32),
                const SizedBox(height: 24),
                Text(
                  verse.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size,
                    height: 2,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  surah.text,
                  style: const TextStyle(color: gold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  reciter.text,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: verse,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'نص الآية'),
          onChanged: (_) => setState(() {}),
        ),
        TextField(
          controller: surah,
          decoration: const InputDecoration(labelText: 'اسم السورة'),
          onChanged: (_) => setState(() {}),
        ),
        TextField(
          controller: reciter,
          decoration: const InputDecoration(labelText: 'اسم القارئ'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        Text('حجم الخط: ${size.round()}'),
        Slider(
          value: size,
          min: 16,
          max: 40,
          onChanged: (v) => setState(() => size = v),
        ),
        const Text('الخلفية'),
        Wrap(
          spacing: 10,
          children: List.generate(
            backgrounds.length,
            (i) => InkWell(
              onTap: () => setState(() => backgroundIndex = i),
              child: CircleAvatar(
                backgroundColor: backgrounds[i],
                child: backgroundIndex == i
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'هذه معاينة فقط. تصدير MP4 ودمج الصوت والانتقالات يحتاج إضافة محرّك فيديو واختباره.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class SettingsTab extends StatelessWidget {
  final double fontSize;
  final bool dark;
  final ValueChanged<double> onFontChanged;
  final ValueChanged<bool> onDarkChanged;

  const SettingsTab({
    super.key,
    required this.fontSize,
    required this.dark,
    required this.onFontChanged,
    required this.onDarkChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'الإعدادات',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('حجم خط القرآن'),
                Slider(
                  value: fontSize,
                  min: 18,
                  max: 38,
                  divisions: 10,
                  label: fontSize.round().toString(),
                  onChanged: onFontChanged,
                ),
                Text('${fontSize.round()}'),
              ],
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('الوضع الليلي'),
          value: dark,
          onChanged: onDarkChanged,
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.offline_bolt_outlined),
            title: Text('العمل دون إنترنت'),
            subtitle: Text(
              'النصوص والمواقيت تُجلب من الإنترنت في هذا الإصدار.',
            ),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.explore_outlined),
            title: Text('اتجاه القبلة'),
            subtitle: Text(
              'البوصلة الحقيقية غير مفعلة في هذا الإصدار.',
            ),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Fakhri Quran'),
            subtitle: Text('تطبيق قرآن وأدوات إسلامية'),
          ),
        ),
      ],
    );
  }
}
