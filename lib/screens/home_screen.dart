// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'undertone_analysis.dart';
import 'my_forma_screen.dart';
import '../models/user_profile_model.dart';
import 'forms_screen.dart';
import 'bodyshape_results.dart';
import 'category_detail_screen.dart';
import '../utils/transitions_helper.dart';

// MainScreen with animated tab transitions
class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final model = Provider.of<UserProfileModel>(context, listen: false);
      model.setNavigationIndex(widget.initialIndex);
      model.loadUserData();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    _fadeController.reset();
    _fadeController.forward();
    Provider.of<UserProfileModel>(
      context,
      listen: false,
    ).setNavigationIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<UserProfileModel>(context);

    Widget formOrResultsScreen;
    if (userProfile.isBodyTypeComplete) {
      formOrResultsScreen = BodyShapeResultsScreen(
        shape: userProfile.bodyType!,
      );
    } else {
      formOrResultsScreen = const FormsScreen();
    }

    final screens = [
      HomeScreenContent(
        onNavigateToForm: () => _onItemTapped(2),
        onNavigateToPalette: () => _onItemTapped(1),
      ),
      const UndertoneAnalysisScreen(),
      formOrResultsScreen,
      const MyFormaScreen(),
    ];

    final selectedIndex = userProfile.navigationIndex;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: IndexedStack(index: selectedIndex, children: screens),
      ),
      bottomNavigationBar: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 100 * (1 - value)),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.palette_outlined),
              activeIcon: Icon(Icons.palette),
              label: 'Palette',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calculate_outlined),
              activeIcon: Icon(Icons.calculate),
              label: 'Form',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'My Forma',
            ),
          ],
          currentIndex: selectedIndex,
          selectedItemColor: const Color(0xFF8B7355),
          unselectedItemColor: Colors.grey.shade500,
          backgroundColor: Colors.white,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
          elevation: 5.0,
        ),
      ),
    );
  }
}

// HomeScreenContent with staggered animations
class HomeScreenContent extends StatelessWidget {
  final VoidCallback onNavigateToForm;
  final VoidCallback onNavigateToPalette;

  const HomeScreenContent({
    super.key,
    required this.onNavigateToForm,
    required this.onNavigateToPalette,
  });

  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<UserProfileModel>(context);

    final List<Widget> contentWidgets = userProfile.isProfileComplete
        ? _buildCompleteProfileContent(context, userProfile)
        : _buildIncompleteProfileContent(context, userProfile);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            userProfile.isProfileComplete ? 'Welcome!' : 'FORMA',
            key: ValueKey(userProfile.isProfileComplete),
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1.0,
      ),
      body: RefreshIndicator(
        onRefresh: () => Provider.of<UserProfileModel>(
          context,
          listen: false,
        ).loadUserData(),
        color: const Color(0xFF8B7355),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
          children: contentWidgets,
        ),
      ),
    );
  }

  List<Widget> _buildIncompleteProfileContent(
    BuildContext context,
    UserProfileModel userProfile,
  ) {
    return [
      StaggeredListItem(
        index: 0,
        baseDelay: const Duration(milliseconds: 50),
        child: _buildProgressSection(userProfile),
      ),
      const SizedBox(height: 30),
      StaggeredListItem(
        index: 1,
        baseDelay: const Duration(milliseconds: 50),
        child: _buildActionCards(
          userProfile,
          onNavigateToForm,
          onNavigateToPalette,
        ),
      ),
      const SizedBox(height: 24),
      StaggeredListItem(
        index: 2,
        baseDelay: const Duration(milliseconds: 50),
        child: _buildCategoryGrid(context, userProfile),
      ),
    ];
  }

  List<Widget> _buildCompleteProfileContent(
    BuildContext context,
    UserProfileModel userProfile,
  ) {
    return [
      StaggeredListItem(
        index: 0,
        baseDelay: const Duration(milliseconds: 50),
        child: _buildResultsSection(userProfile),
      ),
      const SizedBox(height: 30),
      StaggeredListItem(
        index: 1,
        baseDelay: const Duration(milliseconds: 50),
        child: _buildPersonalizedOutfitSection(context, userProfile),
      ),
      const SizedBox(height: 30),
      StaggeredListItem(
        index: 2,
        baseDelay: const Duration(milliseconds: 50),
        child: _buildStyleTipsSection(userProfile),
      ),
      const SizedBox(height: 30),
      StaggeredListItem(
        index: 3,
        baseDelay: const Duration(milliseconds: 50),
        child: _buildColorPaletteSection(userProfile),
      ),
      const SizedBox(height: 30),
      StaggeredListItem(
        index: 4,
        baseDelay: const Duration(milliseconds: 50),
        child: _buildCategoryGrid(context, userProfile),
      ),
      const SizedBox(height: 30),
      StaggeredListItem(
        index: 5,
        baseDelay: const Duration(milliseconds: 50),
        child: _buildActionCards(
          userProfile,
          onNavigateToForm,
          onNavigateToPalette,
        ),
      ),
    ];
  }

  Widget _buildProgressSection(UserProfileModel userProfile) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * value),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userProfile.isProfileComplete
                    ? "Profile Status"
                    : "Complete Your Profile",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressStep(
                    Icons.palette_outlined,
                    "Skin Tone",
                    userProfile.isSkinToneComplete,
                    0,
                  ),
                  _buildProgressLine(userProfile.isSkinToneComplete),
                  _buildProgressStep(
                    Icons.accessibility_new,
                    "Body Type",
                    userProfile.isBodyTypeComplete,
                    1,
                  ),
                  _buildProgressLine(userProfile.isBodyTypeComplete),
                  _buildProgressStep(
                    Icons.check_circle_outline,
                    "Results",
                    userProfile.isProfileComplete,
                    2,
                  ),
                ],
              ),
              if (!userProfile.isProfileComplete) ...[
                const SizedBox(height: 15),
                Text(
                  "Complete these steps to unlock personalized recommendations!",
                  style: GoogleFonts.inter(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressStep(
    IconData icon,
    String label,
    bool completed,
    int index,
  ) {
    return Expanded(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 400 + (index * 100)),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: CircleAvatar(
                radius: 22,
                backgroundColor:
                    (completed ? const Color(0xFF8B7355) : Colors.grey.shade400)
                        .withOpacity(0.15),
                child: Icon(
                  completed ? Icons.check_circle : icon,
                  color: completed
                      ? const Color(0xFF8B7355)
                      : Colors.grey.shade400,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                color: completed ? Colors.black87 : Colors.grey.shade600,
                fontSize: 12,
                fontWeight: completed ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressLine(bool precedingStepCompleted) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        height: 2,
        margin: const EdgeInsets.only(top: 21, left: 4, right: 4),
        color: precedingStepCompleted
            ? const Color(0xFF8B7355).withOpacity(0.5)
            : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildColorPaletteSection(UserProfileModel userProfile) {
    final palette = userProfile.colorPalette;
    if (palette.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.rotate(angle: value * 3.14, child: child);
                  },
                  child: Icon(
                    Icons.color_lens_outlined,
                    color: Color(0xFF8B7355),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "Your Color Palette (${userProfile.skinUndertone})",
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 15.0,
              runSpacing: 10.0,
              children: List.generate(palette.length, (index) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 400 + (index * 100)),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(scale: value, child: child);
                  },
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: palette[index],
                    child: CircleAvatar(
                      radius: 21,
                      backgroundColor: palette[index],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(
    BuildContext context,
    UserProfileModel userProfile,
  ) {
    final isMale = userProfile.gender?.toLowerCase() == "male";
    final isFemale = userProfile.gender?.toLowerCase() == "female";
    final List<Map<String, dynamic>> categories = _generateCategoryList(
      isMale,
      isFemale,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 16.0),
          child: Text(
            "Browse Recommendations",
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.95,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return StaggeredListItem(
              index: index,
              baseDelay: const Duration(milliseconds: 30),
              child: _buildCategoryCard(
                context,
                category['name'] as String,
                category['icon'] as IconData,
                category['color'] as Color,
              ),
            );
          },
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _generateCategoryList(bool isMale, bool isFemale) {
    final List<Map<String, dynamic>> categories = [];
    final color1 = const Color(0xFFB5A491);
    final color2 = const Color(0xFF8B7355);
    final color3 = const Color(0xFFD4C4B0);
    int colorIndex = 0;
    Color nextColor() {
      Color c;
      switch (colorIndex % 3) {
        case 0:
          c = color1;
          break;
        case 1:
          c = color2;
          break;
        default:
          c = color3;
          break;
      }
      colorIndex++;
      return c;
    }

    categories.add({
      'name': 'Sweaters & Knits',
      'icon': Icons.checkroom,
      'color': nextColor(),
    });
    categories.add({
      'name': 'Shirts',
      'icon': Icons.style,
      'color': nextColor(),
    });
    categories.add({
      'name': 'T-Shirts & Casual Tops',
      'icon': Icons.emoji_people,
      'color': nextColor(),
    });
    if (isFemale)
      categories.add({
        'name': 'Blouses & Tops',
        'icon': Icons.woman,
        'color': nextColor(),
      });
    categories.add({
      'name': 'Trousers & Pants',
      'icon': Icons.airline_seat_legroom_normal,
      'color': nextColor(),
    });
    categories.add({
      'name': 'Jeans & Denim',
      'icon': Icons.folder_zip_outlined,
      'color': nextColor(),
    });
    categories.add({
      'name': 'Shorts',
      'icon': Icons.beach_access,
      'color': nextColor(),
    });
    if (isFemale) {
      categories.add({
        'name': 'Skirts',
        'icon': Icons.stroller,
        'color': nextColor(),
      });
      categories.add({
        'name': 'Dresses',
        'icon': Icons.nightlife,
        'color': nextColor(),
      });
      categories.add({
        'name': 'Jumpsuits & Rompers',
        'icon': Icons.accessibility_new,
        'color': nextColor(),
      });
    }
    categories.add({
      'name': 'Blazers & Jackets',
      'icon': Icons.business_center,
      'color': nextColor(),
    });
    categories.add({
      'name': 'Coats',
      'icon': Icons.ac_unit,
      'color': nextColor(),
    });
    categories.add({
      'name': 'Shoes',
      'icon': Icons.ice_skating,
      'color': nextColor(),
    });
    categories.add({
      'name': 'Bags & Accessories',
      'icon': isFemale ? Icons.shopping_bag_outlined : Icons.work_outline,
      'color': nextColor(),
    });
    categories.add({
      'name': 'Scarves & Ties',
      'icon': Icons.square_foot,
      'color': nextColor(),
    });

    return categories;
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String categoryName,
    IconData icon,
    Color color,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1.0,
      shadowColor: Colors.grey.withOpacity(0.2),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.elegantNavigateTo(
            CategoryDetailScreen(categoryName: categoryName),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: color.withOpacity(0.15),
                  child: Icon(icon, color: color, size: 24),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                categoryName,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCards(
    UserProfileModel userProfile,
    VoidCallback onNavigateToForm,
    VoidCallback onNavigateToPalette,
  ) {
    return Column(
      children: [
        _buildActionCard(
          title: "Analyze Skin Tone",
          description: "Identify your undertone for the perfect color palette.",
          icon: Icons.palette_outlined,
          isCompleted: userProfile.isSkinToneComplete,
          onTap: onNavigateToPalette,
          index: 0,
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          title: "Calculate Body Type",
          description: "Discover your body shape for tailored fit advice.",
          icon: Icons.accessibility_new,
          isCompleted: userProfile.isBodyTypeComplete,
          onTap: onNavigateToForm,
          index: 1,
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required IconData icon,
    required bool isCompleted,
    required VoidCallback onTap,
    required int index,
  }) {
    final themeColor = const Color(0xFF8B7355);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Card(
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isCompleted
                ? themeColor.withOpacity(0.5)
                : Colors.grey.shade300,
            width: 1,
          ),
        ),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor:
                        (isCompleted ? themeColor : Colors.grey.shade400)
                            .withOpacity(0.15),
                    child: Icon(
                      isCompleted ? Icons.check_circle_outline : icon,
                      color: isCompleted ? themeColor : Colors.grey.shade600,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        description,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

buildProgressSection(UserProfileModel userProfile) {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.0, end: 1.0),
    duration: const Duration(milliseconds: 600),
    curve: Curves.easeOut,
    builder: (context, value, child) {
      return Transform.scale(
        scale: 0.9 + (0.1 * value),
        child: Opacity(opacity: value, child: child),
      );
    },
    child: Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userProfile.isProfileComplete
                  ? "Profile Status"
                  : "Complete Your Profile",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressStep(
                  Icons.palette_outlined,
                  "Skin Tone",
                  userProfile.isSkinToneComplete,
                  0,
                ),
                _buildProgressLine(userProfile.isSkinToneComplete),
                _buildProgressStep(
                  Icons.accessibility_new,
                  "Body Type",
                  userProfile.isBodyTypeComplete,
                  1,
                ),
                _buildProgressLine(userProfile.isBodyTypeComplete),
                _buildProgressStep(
                  Icons.check_circle_outline,
                  "Results",
                  userProfile.isProfileComplete,
                  2,
                ),
              ],
            ),
            if (!userProfile.isProfileComplete) ...[
              const SizedBox(height: 15),
              Text(
                "Complete these steps to unlock personalized recommendations!",
                style: GoogleFonts.inter(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

Widget _buildProgressStep(
  IconData icon,
  String label,
  bool completed,
  int index,
) {
  return Expanded(
    child: TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: CircleAvatar(
              radius: 22,
              backgroundColor:
                  (completed ? const Color(0xFF8B7355) : Colors.grey.shade400)
                      .withOpacity(0.15),
              child: Icon(
                completed ? Icons.check_circle : icon,
                color: completed
                    ? const Color(0xFF8B7355)
                    : Colors.grey.shade400,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              color: completed ? Colors.black87 : Colors.grey.shade600,
              fontSize: 12,
              fontWeight: completed ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

Widget _buildProgressLine(bool precedingStepCompleted) {
  return Expanded(
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      height: 2,
      margin: const EdgeInsets.only(top: 21, left: 4, right: 4),
      color: precedingStepCompleted
          ? const Color(0xFF8B7355).withOpacity(0.5)
          : Colors.grey.shade300,
    ),
  );
}

Widget _buildResultsSection(UserProfileModel userProfile) {
  return Card(
    elevation: 2.0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Style Profile",
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          _buildResultItem("Gender:", userProfile.gender ?? "N/A", 0),
          const Divider(height: 20, thickness: 0.5),
          _buildResultItem("Body Type:", userProfile.bodyType ?? "N/A", 1),
          const Divider(height: 20, thickness: 0.5),
          _buildResultItem(
            "Skin Undertone:",
            userProfile.skinUndertone ?? "N/A",
            2,
          ),
        ],
      ),
    ),
  );
}

Widget _buildResultItem(String label, String value, int index) {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.0, end: 1.0),
    duration: Duration(milliseconds: 300 + (index * 100)),
    curve: Curves.easeOut,
    builder: (context, animValue, child) {
      return Opacity(
        opacity: animValue,
        child: Transform.translate(
          offset: Offset(20 * (1 - animValue), 0),
          child: child,
        ),
      );
    },
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            color: const Color(0xFF8B7355),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    ),
  );
}

Widget _buildPersonalizedOutfitSection(
  BuildContext context,
  UserProfileModel userProfile,
) {
  final selectedOutfit = userProfile.selectedOutfit;

  return Card(
    elevation: 2.0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    clipBehavior: Clip.antiAlias,
    child: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B7355), Color(0xFFB5A491)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.rotate(
                          angle: value * 6.28,
                          child: child,
                        );
                      },
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Your Perfect Outfit",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                if (selectedOutfit.isNotEmpty)
                  AnimatedScale(
                    scale: selectedOutfit.isNotEmpty ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Clear Outfit?"),
                            content: const Text(
                              "Are you sure you want to remove all items from your outfit?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  userProfile.clearOutfit();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Outfit cleared'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Clear",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                      tooltip: 'Clear outfit',
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: selectedOutfit.isEmpty
                    ? _buildOutfitEmptyState()
                    : _buildOutfitItemsList(
                        context,
                        userProfile,
                        selectedOutfit,
                      ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildOutfitEmptyState() {
  return Padding(
    key: const ValueKey('empty'),
    padding: const EdgeInsets.symmetric(vertical: 20.0),
    child: Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: Icon(
            Icons.checkroom_outlined,
            size: 40,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Build your outfit!",
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Browse categories and tap the ❤️ on items you like.",
          style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

Widget _buildOutfitItemsList(
  BuildContext context,
  UserProfileModel userProfile,
  Map<String, String> selectedOutfit,
) {
  return Column(
    key: const ValueKey('items'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: selectedOutfit.entries.map((entry) {
      final index = selectedOutfit.keys.toList().indexOf(entry.key);
      return StaggeredListItem(
        index: index,
        baseDelay: const Duration(milliseconds: 50),
        child: _buildOutfitItem(context, userProfile, entry.key, entry.value),
      );
    }).toList(),
  );
}

Widget _buildOutfitItem(
  BuildContext context,
  UserProfileModel userProfile,
  String category,
  String itemName,
) {
  final clothingItem = userProfile.getClothingItem(category, itemName);

  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Material(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 50,
                  height: 50,
                  color: _getPlaceholderColorForItem(itemName),
                  child: clothingItem.imageUrl != null
                      ? Image.network(
                          clothingItem.imageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) =>
                              progress == null
                              ? child
                              : Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value: progress.expectedTotalBytes != null
                                        ? progress.cumulativeBytesLoaded /
                                              progress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                          errorBuilder: (context, error, stackTrace) => Icon(
                            _getIconForItemName(itemName),
                            size: 24,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        )
                      : Icon(
                          _getIconForItemName(itemName),
                          size: 24,
                          color: Colors.white.withOpacity(0.7),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemName,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      category,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF8B7355),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                onPressed: () {
                  userProfile.removeOutfitItem(category);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$itemName removed'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                icon: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Color _getPlaceholderColorForItem(String itemName) {
  final colorMap = {
    'warm': [
      const Color(0xFFD4AF37),
      const Color(0xFFCD853F),
      const Color(0xFFDAA520),
      const Color(0xFFB8860B),
    ],
    'cool': [
      const Color(0xFF4169E1),
      const Color(0xFF8A2BE2),
      const Color(0xFF20B2AA),
      const Color(0xFF9370DB),
    ],
    'neutral': [
      const Color(0xFF708090),
      const Color(0xFF2E8B57),
      const Color(0xFF800080),
      const Color(0xFFB22222),
    ],
  };

  final lowerName = itemName.toLowerCase();
  if (lowerName.contains('warm') ||
      lowerName.contains('camel') ||
      lowerName.contains('rust') ||
      lowerName.contains('olive') ||
      lowerName.contains('honey') ||
      lowerName.contains('terracotta')) {
    return colorMap['warm']![itemName.hashCode % 4];
  } else if (lowerName.contains('cool') ||
      lowerName.contains('navy') ||
      lowerName.contains('teal') ||
      lowerName.contains('lavender') ||
      lowerName.contains('charcoal')) {
    return colorMap['cool']![itemName.hashCode % 4];
  }
  return colorMap['neutral']![itemName.hashCode % 4];
}

IconData _getIconForItemName(String itemName) {
  final lowerName = itemName.toLowerCase();
  if (lowerName.contains('dress')) return Icons.checkroom;
  if (lowerName.contains('shirt') || lowerName.contains('blouse'))
    return Icons.shopping_bag;
  if (lowerName.contains('pants') ||
      lowerName.contains('jeans') ||
      lowerName.contains('trousers'))
    return Icons.yard;
  if (lowerName.contains('jacket') ||
      lowerName.contains('blazer') ||
      lowerName.contains('coat'))
    return Icons.dry_cleaning;
  if (lowerName.contains('shoes') ||
      lowerName.contains('boots') ||
      lowerName.contains('sneakers'))
    return Icons.shopping_basket;
  if (lowerName.contains('bag')) return Icons.work_outline;
  if (lowerName.contains('scarf') || lowerName.contains('tie'))
    return Icons.interests;
  return Icons.checkroom;
}

Widget _buildStyleTipsSection(UserProfileModel userProfile) {
  final tips = userProfile.styleTips;
  if (tips.isEmpty) return const SizedBox.shrink();

  return Card(
    elevation: 2.0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(scale: value, child: child),
                  );
                },
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: Color(0xFF8B7355),
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "Style Tips",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Icon(Icons.check, color: Color(0xFF8B7355), size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tips.first,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
