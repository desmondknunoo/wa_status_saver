import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/status_provider.dart';
import '../widgets/status_grid.dart';
import '../widgets/permission_view.dart';
import '../widgets/empty_state.dart';
import 'saved_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatusProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentNavIndex == 0 ? _buildStatusView() : const SavedScreen(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildStatusView() {
    return Consumer<StatusProvider>(
      builder: (context, provider, _) {
        if (!provider.hasPermission) {
          return PermissionView(
            onRequestPermission: () => provider.requestPermission(),
          );
        }

        return NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _buildAppBar(provider),
              SliverToBoxAdapter(child: _buildTabBar()),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildStatusList(
                provider.whatsappStatuses,
                provider.isLoading,
                'WhatsApp',
              ),
              _buildStatusList(
                provider.businessStatuses,
                provider.isLoading,
                'Business',
              ),
            ],
          ),
        );
      },
    );
  }

  SliverAppBar _buildAppBar(StatusProvider provider) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Status Saver',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFF25D366), const Color(0xFF128C7E)],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: provider.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.refresh_rounded),
          onPressed: provider.isLoading
              ? null
              : () => provider.refreshAllStatuses(),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Consumer<StatusProvider>(
      builder: (context, provider, _) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF25D366),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            dividerColor: Colors.transparent,
            padding: const EdgeInsets.all(4),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.chat_bubble_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text('WhatsApp (${provider.whatsappCount})'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.business_center_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text('Business (${provider.businessCount})'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusList(
    List<StatusModel> statuses,
    bool isLoading,
    String type,
  ) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF25D366)),
            SizedBox(height: 16),
            Text('Loading statuses...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (statuses.isEmpty) {
      return EmptyState(
        icon: Icons.photo_library_outlined,
        title: 'No $type Statuses',
        subtitle:
            'View some statuses on $type first,\nthen come back here to save them.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<StatusProvider>().refreshAllStatuses(),
      color: const Color(0xFF25D366),
      child: StatusGrid(statuses: statuses),
    );
  }

  Widget _buildBottomNav() {
    return Consumer<StatusProvider>(
      builder: (context, provider, _) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    isSelected: _currentNavIndex == 0,
                    onTap: () => setState(() => _currentNavIndex = 0),
                  ),
                  _buildNavItem(
                    icon: Icons.download_rounded,
                    label: 'Saved',
                    isSelected: _currentNavIndex == 1,
                    badge: provider.savedCount > 0
                        ? provider.savedCount.toString()
                        : null,
                    onTap: () => setState(() => _currentNavIndex = 1),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    String? badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF25D366).withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Icon(
                  icon,
                  color: isSelected ? const Color(0xFF25D366) : Colors.grey,
                  size: 26,
                ),
                if (badge != null)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF25D366),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF25D366),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
