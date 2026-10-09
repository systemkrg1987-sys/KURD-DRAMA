import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KurdDramaApp());
}

const gold = Color(0xFFFFC34D);
const bg = Color(0xFF070B11);
const panel = Color(0xFF101821);
const border = Color(0xFF263340);

class Drama {
  final int id;
  final String title;
  final int year;
  final String genre;
  final int episodes;
  final String description;
  final String image;

  const Drama({
    required this.id,
    required this.title,
    required this.year,
    required this.genre,
    required this.episodes,
    required this.description,
    required this.image,
  });
}

const dramas = <Drama>[
  Drama(
    id: 1,
    title: 'هەتا ساڵان',
    year: 2024,
    genre: 'دراما',
    episodes: 20,
    description: 'چیرۆکێکی دراماتیکی کوردی لەسەر خێزان، بڕیار و هەڵبژاردنی ژیان.',
    image: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&w=900&q=80',
  ),
  Drama(
    id: 2,
    title: 'ڕێگای خۆف',
    year: 2025,
    genre: 'دراما / ئەکشن',
    episodes: 16,
    description: 'چیرۆکی گەنجێک کە لە نێوان خۆشەویستی و مەترسییەکی گەورەدا دەکەوێت.',
    image: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?auto=format&fit=crop&w=900&q=80',
  ),
  Drama(
    id: 3,
    title: 'دوورەوە',
    year: 2023,
    genre: 'کۆمەڵایەتی',
    episodes: 12,
    description: 'درامایەکی کۆمەڵایەتی دەربارەی خێزان و کێشەکانی ژیانی ڕۆژانە.',
    image: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=900&q=80',
  ),
  Drama(
    id: 4,
    title: 'سێبەر',
    year: 2022,
    genre: 'ڕازاوی',
    episodes: 18,
    description: 'رازێک لە شارێکی بچووکدا دەکرێتەوە و ژیانی چەند کەسێک دەگۆڕێت.',
    image: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=900&q=80',
  ),
];

class KurdDramaApp extends StatelessWidget {
  const KurdDramaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KURD DRAMA',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: gold,
          brightness: Brightness.dark,
        ),
        fontFamily: 'Arial',
        useMaterial3: true,
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;
  Set<int> favorites = {};
  Set<int> continued = {};
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      favorites = (prefs.getStringList('favorites') ?? [])
          .map(int.parse)
          .toSet();
      continued = (prefs.getStringList('continued') ?? [])
          .map(int.parse)
          .toSet();
    });
  }

  Future<void> toggleFavorite(int id) async {
    setState(() {
      if (favorites.contains(id)) {
        favorites.remove(id);
      } else {
        favorites.add(id);
      }
    });
    await prefs.setStringList(
      'favorites',
      favorites.map((e) => e.toString()).toList(),
    );
  }

  Future<void> markContinued(int id) async {
    setState(() => continued.add(id));
    await prefs.setStringList(
      'continued',
      continued.map((e) => e.toString()).toList(),
    );
  }

  void openDrama(Drama drama) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DramaDetailsPage(
          drama: drama,
          isFavorite: favorites.contains(drama.id),
          onFavorite: () => toggleFavorite(drama.id),
          onPlay: (episode) => markContinued(drama.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        favorites: favorites,
        continued: continued,
        onDrama: openDrama,
      ),
      DramasPage(onDrama: openDrama),
      SearchPage(onDrama: openDrama),
      FavoritesPage(
        favorites: favorites,
        onDrama: openDrama,
      ),
      AccountPage(
        onAdmin: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminPage()),
        ),
      ),
    ];

    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: IndexedStack(index: index, children: pages),
      ),
      bottomNavigationBar: Directionality(
        textDirection: TextDirection.rtl,
        child: NavigationBar(
          selectedIndex: index,
          backgroundColor: const Color(0xFF080D14),
          indicatorColor: const Color(0x33263B4D),
          onDestinationSelected: (i) => setState(() => index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'سەرەکی'),
            NavigationDestination(icon: Icon(Icons.movie_outlined), selectedIcon: Icon(Icons.movie), label: 'دراماکان'),
            NavigationDestination(icon: Icon(Icons.search), label: 'گەڕان'),
            NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'دڵخوازەکان'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'هەژمار'),
          ],
        ),
      ),
    );
  }
}

class AppBarTitle extends StatelessWidget {
  const AppBarTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      '🎬 KURD DRAMA',
      style: TextStyle(fontWeight: FontWeight.w800, color: gold),
    );
  }
}

class HomePage extends StatelessWidget {
  final Set<int> favorites;
  final Set<int> continued;
  final void Function(Drama) onDrama;

  const HomePage({
    super.key,
    required this.favorites,
    required this.continued,
    required this.onDrama,
  });

  @override
  Widget build(BuildContext context) {
    final continueList = dramas.where((d) => continued.contains(d.id)).toList();

    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          pinned: true,
          backgroundColor: bg,
          title: AppBarTitle(),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: _HeroCard(onTap: () => onDrama(dramas.first)),
          ),
        ),
        const SliverToBoxAdapter(
          child: SectionTitle(title: 'نوێترین دراماکان'),
        ),
        DramaGrid(dramas: dramas, onDrama: onDrama),
        if (continueList.isNotEmpty) ...[
          const SliverToBoxAdapter(
            child: SectionTitle(title: 'بەردەوامبوون لە بینین'),
          ),
          DramaGrid(dramas: continueList, onDrama: onDrama),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final VoidCallback onTap;
  const _HeroCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        height: 310,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(dramas.first.image, fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [Colors.black.withOpacity(.95), Colors.transparent],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('درامای نوێ', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),
                    const Text('هەتا ساڵان', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('ئێستا بەشی نوێ ببینە.', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.black),
                      onPressed: onTap,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('بینین'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }
}

class DramaGrid extends StatelessWidget {
  final List<Drama> dramas;
  final void Function(Drama) onDrama;
  const DramaGrid({super.key, required this.dramas, required this.onDrama});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, i) => DramaCard(drama: dramas[i], onTap: () => onDrama(dramas[i])),
          childCount: dramas.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: .64,
        ),
      ),
    );
  }
}

class DramaCard extends StatelessWidget {
  final Drama drama;
  final VoidCallback onTap;
  const DramaCard({super.key, required this.drama, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: Image.network(drama.image, fit: BoxFit.cover)),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(drama.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${drama.year} • ${drama.genre}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.white60)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DramasPage extends StatelessWidget {
  final void Function(Drama) onDrama;
  const DramasPage({super.key, required this.onDrama});

  @override
  Widget build(BuildContext context) => CustomScrollView(
    slivers: [
      const SliverAppBar(pinned: true, backgroundColor: bg, title: AppBarTitle()),
      const SliverToBoxAdapter(child: SectionTitle(title: 'هەموو دراماکان')),
      DramaGrid(dramas: dramas, onDrama: onDrama),
    ],
  );
}

class SearchPage extends StatefulWidget {
  final void Function(Drama) onDrama;
  const SearchPage({super.key, required this.onDrama});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final list = dramas.where((d) => '${d.title} ${d.genre}'.contains(query)).toList();
    return CustomScrollView(
      slivers: [
        const SliverAppBar(pinned: true, backgroundColor: bg, title: Text('گەڕان')),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: TextField(
              onChanged: (v) => setState(() => query = v),
              decoration: InputDecoration(
                hintText: 'ناوی دراما یان ژانەر...',
                filled: true,
                fillColor: panel,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
        ),
        DramaGrid(dramas: list, onDrama: widget.onDrama),
      ],
    );
  }
}

class FavoritesPage extends StatelessWidget {
  final Set<int> favorites;
  final void Function(Drama) onDrama;
  const FavoritesPage({super.key, required this.favorites, required this.onDrama});

  @override
  Widget build(BuildContext context) {
    final list = dramas.where((d) => favorites.contains(d.id)).toList();
    return CustomScrollView(
      slivers: [
        const SliverAppBar(pinned: true, backgroundColor: bg, title: Text('دڵخوازەکان')),
        if (list.isEmpty)
          const SliverFillRemaining(child: Center(child: Text('هێشتا هیچ درامایەکت دڵخواز نەکردووە.')))
        else
          DramaGrid(dramas: list, onDrama: onDrama),
      ],
    );
  }
}

class DramaDetailsPage extends StatelessWidget {
  final Drama drama;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final void Function(int) onPlay;

  const DramaDetailsPage({
    super.key,
    required this.drama,
    required this.isFavorite,
    required this.onFavorite,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 390,
              pinned: true,
              backgroundColor: bg,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(drama.title),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(drama.image, fit: BoxFit.cover),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(spacing: 7, children: [
                      _Chip(text: drama.genre),
                      _Chip(text: '${drama.year}'),
                      _Chip(text: '${drama.episodes} زنجیرە'),
                    ]),
                    const SizedBox(height: 12),
                    Text(drama.description, style: const TextStyle(color: Colors.white70, height: 1.8)),
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.black),
                          onPressed: () {
                            onPlay(1);
                            Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerPage(drama: drama, episode: 1)));
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('زنجیرەی 01 ببینە'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: onFavorite,
                        icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.redAccent : Colors.white),
                      ),
                    ]),
                    const SizedBox(height: 18),
                    const Text('زنجیرەکان', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...List.generate(drama.episodes, (i) {
                      final ep = i + 1;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(drama.image, width: 82, height: 54, fit: BoxFit.cover),
                          ),
                          title: Text('زنجیرە ${ep.toString().padLeft(2, '0')}'),
                          subtitle: const Text('03:00', style: TextStyle(color: Colors.white54)),
                          trailing: IconButton(
                            style: IconButton.styleFrom(backgroundColor: gold),
                            color: Colors.black,
                            onPressed: () {
                              onPlay(ep);
                              Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerPage(drama: drama, episode: ep)));
                            },
                            icon: const Icon(Icons.play_arrow),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) => Chip(
    label: Text(text, style: const TextStyle(fontSize: 11)),
    backgroundColor: const Color(0xFF16212D),
    side: const BorderSide(color: border),
  );
}

class PlayerPage extends StatefulWidget {
  final Drama drama;
  final int episode;
  const PlayerPage({super.key, required this.drama, required this.episode});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.networkUrl(
      Uri.parse('https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4'),
    )..initialize().then((_) {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.drama.title} — زنجیرە ${widget.episode.toString().padLeft(2, '0')}')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            AspectRatio(
              aspectRatio: controller.value.isInitialized ? controller.value.aspectRatio : 16 / 9,
              child: controller.value.isInitialized
                  ? Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        VideoPlayer(controller),
                        VideoProgressIndicator(controller, allowScrubbing: true),
                      ],
                    )
                  : const Center(child: CircularProgressIndicator(color: gold)),
            ),
            const SizedBox(height: 12),
            Wrap(spacing: 7, children: const [
              _Chip(text: 'Auto'),
              _Chip(text: '720p'),
              _Chip(text: '1080p'),
              _Chip(text: '4K'),
            ]),
            const SizedBox(height: 12),
            Text(widget.drama.description, style: const TextStyle(color: Colors.white70, height: 1.8)),
            const SizedBox(height: 12),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.black),
              onPressed: () => setState(() {
                if (controller.value.isPlaying) {
                  controller.pause();
                } else {
                  controller.play();
                }
              }),
              icon: Icon(controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
              label: Text(controller.value.isPlaying ? 'وەستاندن' : 'دەستپێکردن'),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountPage extends StatelessWidget {
  final VoidCallback onAdmin;
  const AccountPage({super.key, required this.onAdmin});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const SizedBox(height: 20),
      const CircleAvatar(radius: 38, backgroundColor: panel, child: Icon(Icons.person, size: 40)),
      const SizedBox(height: 12),
      const Center(child: Text('بەکارهێنەر', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
      const Center(child: Text('user@example.com', style: TextStyle(color: Colors.white54))),
      const SizedBox(height: 25),
      Card(
        color: panel,
        child: ListTile(
          leading: const Icon(Icons.admin_panel_settings, color: gold),
          title: const Text('Admin Dashboard'),
          subtitle: const Text('بەڕێوەبردنی دراماکان و زنجیرەکان'),
          trailing: const Icon(Icons.chevron_left),
          onTap: onAdmin,
        ),
      ),
    ],
  );
}

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final List<Drama> items = List.of(dramas);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            Row(
              children: [
                _AdminStat(title: 'دراما', value: '${items.length}'),
                _AdminStat(title: 'زنجیرە', value: '${items.fold<int>(0, (a, d) => a + d.episodes)}'),
              ],
            ),
            const SizedBox(height: 10),
            const Text('بەڕێوەبردنی دراماکان', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...items.map((d) => Card(
              color: panel,
              child: ListTile(
                leading: ClipRRect(borderRadius: BorderRadius.circular(7), child: Image.network(d.image, width: 55, height: 55, fit: BoxFit.cover)),
                title: Text(d.title),
                subtitle: Text('${d.year} • ${d.episodes} زنجیرە'),
                trailing: const Icon(Icons.edit_outlined),
              ),
            )),
            const SizedBox(height: 12),
            const Text(
              'تێبینی: ئەم Admin ـە وەشانی MVP ـە. بۆ وەشانی پڕۆداکشن Login، Database، Upload و دەسەڵاتی بەکارهێنەر زیاد دەکرێن.',
              style: TextStyle(color: Colors.white54, height: 1.7),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminStat extends StatelessWidget {
  final String title;
  final String value;
  const _AdminStat({required this.title, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Colors.white54)),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(fontSize: 27, color: gold, fontWeight: FontWeight.bold)),
      ]),
    ),
  );
}
