import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class ClothingItem {
  final String name;
  final String? imageUrl;
  final String? description;

  ClothingItem({required this.name, this.imageUrl, this.description});

  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    return ClothingItem(
      name: json['name'] as String,
      imageUrl: json['url'] as String?, // Matches the 'url' field from your DB
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'imageUrl': imageUrl, 'description': description};
  }
}

class UserProfileModel extends ChangeNotifier {
  String? username;
  String? gender;
  String? bodyType;
  String? skinUndertone;

  int _navigationIndex = 0;
  int get navigationIndex => _navigationIndex;

  Map<String, List<ClothingItem>> _clothingRecommendations = {};
  Map<String, String> _selectedOutfit = <String, String>{};

  // --- Wardrobe Builder Methods ---
  Future<void> selectOutfitItem(String category, String itemName) async {
    _selectedOutfit[category] = itemName;
    notifyListeners();
    await AuthService.updateProfile({'selectedOutfit': _selectedOutfit});
  }

  void removeOutfitItem(String category) {
    _selectedOutfit.remove(category);
    notifyListeners();
  }

  bool isItemSelected(String category, String itemName) {
    return _selectedOutfit[category] == itemName;
  }

  String? getSelectedItem(String category) {
    return _selectedOutfit[category];
  }

  List<String> get selectedOutfitItems {
    return _selectedOutfit.values.toList();
  }

  void clearOutfit() {
    _selectedOutfit.clear();
    notifyListeners();
  }

  Map<String, String> get selectedOutfit {
    return Map.from(_selectedOutfit);
  }

  // --- Data Fetching Methods ---
  Future<void> fetchRecommendations() async {
    if (!isProfileComplete) return;

    final recommendations = await ApiService.getRecommendations(
      gender: gender!,
      bodyType: bodyType!,
      skinUndertone: skinUndertone!,
    );

    _clothingRecommendations = recommendations;
    notifyListeners();
  }

  ClothingItem getClothingItem(String category, String itemName) {
    if (_clothingRecommendations.containsKey(category)) {
      return _clothingRecommendations[category]!.firstWhere(
        (item) => item.name == itemName,
        orElse: () => ClothingItem(name: itemName),
      );
    }
    return ClothingItem(name: itemName);
  }

  // --- Navigation & State ---
  void setNavigationIndex(int index) {
    if (_navigationIndex == index) return;
    _navigationIndex = index;
    notifyListeners();
  }

  bool get isBodyTypeComplete => bodyType != null && bodyType!.isNotEmpty;
  bool get isSkinToneComplete =>
      skinUndertone != null && skinUndertone!.isNotEmpty;
  bool get isGenderComplete => gender != null && gender!.isNotEmpty;
  bool get isProfileComplete =>
      isBodyTypeComplete && isSkinToneComplete && isGenderComplete;

  // --- User Profile Updaters ---
  void updateUsername(String name) {
    username = name;
    notifyListeners();
  }

  void updateGender(String g) {
    gender = g;
    notifyListeners();
  }

  Future<void> updateBodyType(String? type) async {
    bodyType = type;
    _navigationIndex = 2;
    notifyListeners();
    await AuthService.updateProfile({'bodyType': type});
    await fetchRecommendations();
  }

  Future<void> updateSkinTone(String tone) async {
    skinUndertone = tone;
    notifyListeners();
    await AuthService.updateProfile({'skinUndertone': tone});
    await fetchRecommendations();
  }

  Future<void> loadUserData() async {
    final result = await AuthService.getUserProfile();
    if (result['success']) {
      final user = result['user'];
      username = user['name'];
      gender = user['gender'];
      bodyType = user['bodyType'];
      skinUndertone = user['skinUndertone'];
      if (user['selectedOutfit'] != null) {
        _selectedOutfit = Map<String, String>.from(user['selectedOutfit']);
      }
      notifyListeners();
      await fetchRecommendations();
    }
  }

  // --- Getters for UI ---
  Map<String, List<ClothingItem>> get styleRecommendations {
    if (!isProfileComplete) {
      return {};
    }
    return _clothingRecommendations;
  }

  List<String> get styleTips {
    if (!isProfileComplete) return [];

    final isMale = gender?.toLowerCase() == "male";
    final isFemale = gender?.toLowerCase() == "female";

    if (isFemale) {
      switch (bodyType?.toLowerCase()) {
        case "hourglass":
          return [
            "Emphasize your defined waist with fitted, stretchy fabrics",
            "Wear ${_getColorForUndertone('warm', 'cool', 'neutral')}-toned wrap dresses and belted styles",
            "Choose bodycon silhouettes that hug your curves",
            "Opt for high-waisted bottoms to highlight proportions",
            "V-necks and scoop necks balance your figure beautifully",
          ];
        case "pear":
        case "triangle":
          return [
            "Draw attention upward with statement tops and necklaces",
            "Wear boat necks and off-shoulder styles to balance hips",
            "Choose darker colors for bottoms, brighter for tops",
            "Structured shoulders and embellishments add upper body volume",
            "A-line skirts and bootcut jeans flatter your silhouette",
          ];
        case "inverted triangle":
          return [
            "Create volume on your lower half with flared skirts",
            "V-necks and vertical details elongate your torso",
            "Avoid heavy shoulder embellishments",
            "Wide-leg pants and palazzo styles balance broad shoulders",
            "Empire waist and A-line dresses work perfectly",
          ];
        case "rectangle":
          return [
            "Create curves with peplum tops and belted dresses",
            "Layer different textures to add dimension",
            "Ruffles and embellishments create waist definition",
            "Fit-and-flare silhouettes add feminine curves",
            "Color blocking at the waist creates visual interest",
          ];
        case "apple":
        case "oval":
          return [
            "V-necks and scoop necks elongate your torso",
            "Empire waist dresses draw attention away from midsection",
            "A-line tunics and flowing fabrics are flattering",
            "Showcase your legs with statement shoes and skirts",
            "Wrap tops and dresses define your silhouette",
          ];
      }
    } else if (isMale) {
      switch (bodyType?.toLowerCase()) {
        case "ectomorph":
          return [
            "Layer with heavier fabrics like tweed, flannel, and corduroy",
            "Horizontal stripes and patterns add visual width",
            "Structured jackets with strong shoulders create bulk",
            "Light colors make your chest and shoulders appear broader",
            "Fitted (not tight) shirts show off your lean physique",
          ];
        case "mesomorph":
          return [
            "Wear fitted shirts that showcase your athletic build",
            "Balanced fabrics like wool, cotton, and linen work best",
            "Tapered trousers complement your proportional frame",
            "Blazers with defined waists highlight your V-shape",
            "Avoid overly baggy clothes that hide your physique",
          ];
        case "endomorph":
          return [
            "Choose lightweight, breathable fabrics to avoid bulk",
            "Vertical stripes and patterns create a slimming effect",
            "Longline jackets elongate your silhouette",
            "Dark colors and monochromatic outfits are slimming",
            "Well-tailored pieces are essential for a polished look",
          ];
      }
    }
    return [];
  }

  List<Color> get colorPalette {
    if (!isSkinToneComplete) return [];

    switch (skinUndertone?.toLowerCase()) {
      case 'warm':
        return [
          const Color(0xFFD4AF37),
          const Color(0xFFCD853F),
          const Color(0xFFDAA520),
          const Color(0xFFB8860B),
          const Color(0xFFFF6347),
        ];
      case 'cool':
        return [
          const Color(0xFF4169E1),
          const Color(0xFF8A2BE2),
          const Color(0xFF20B2AA),
          const Color(0xFF9370DB),
          const Color(0xFF008B8B),
        ];
      default:
        return [
          const Color(0xFF708090),
          const Color(0xFF2E8B57),
          const Color(0xFF800080),
          const Color(0xFFB22222),
          const Color(0xFF4682B4),
        ];
    }
  }

  String _getColorForUndertone(
    String warmColor,
    String coolColor,
    String neutralColor,
  ) {
    final tone = skinUndertone?.toLowerCase() ?? "neutral";
    switch (tone) {
      case 'warm':
        return warmColor;
      case 'cool':
        return coolColor;
      default:
        return neutralColor;
    }
  }
}
