// lib/models/user_profile_model.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // New ClothingItem class to hold image data

class ClothingItem {
  final String name;
  final String? imageUrl; // MongoDB image URL will go here
  final String? description;

  ClothingItem({required this.name, this.imageUrl, this.description});

  // Factory constructor for MongoDB integration
  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    return ClothingItem(
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String?,
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

  // Storage for MongoDB clothing items
  Map<String, List<ClothingItem>> _clothingDatabase = {};

  // User's selected outfit items (one per category)
  Map<String, String> _selectedOutfit = <String, String>{};

  // -------------------
  // Wardrobe Builder Methods
  // -------------------

  // Add item to selected outfit (replaces any existing item in that category)
  Future<void> selectOutfitItem(String category, String itemName) async {
    _selectedOutfit[category] = itemName;
    notifyListeners();

    // Save to MongoDB
    await AuthService.updateProfile({'selectedOutfit': _selectedOutfit});
  }

  // Remove item from selected outfit
  void removeOutfitItem(String category) {
    _selectedOutfit.remove(category);
    notifyListeners();
  }

  // Check if an item is selected in a category
  bool isItemSelected(String category, String itemName) {
    return _selectedOutfit[category] == itemName;
  }

  // Get selected item for a category
  String? getSelectedItem(String category) {
    return _selectedOutfit[category];
  }

  // Get all selected outfit items
  List<String> get selectedOutfitItems {
    return _selectedOutfit.values.toList();
  }

  // Clear entire outfit
  void clearOutfit() {
    _selectedOutfit.clear();
    notifyListeners();
  }

  // Get selected outfit as map (category -> itemName)
  Map<String, String> get selectedOutfit {
    return Map.from(_selectedOutfit);
  }

  // -------------------
  // MongoDB Integration Methods
  // -------------------

  // Load clothing items from MongoDB
  void loadClothingItems(Map<String, List<ClothingItem>> items) {
    _clothingDatabase = items;
    notifyListeners();
  }

  // Get a specific clothing item by category and name
  ClothingItem getClothingItem(String category, String itemName) {
    // Check if we have this item in database
    if (_clothingDatabase.containsKey(category)) {
      final item = _clothingDatabase[category]!.firstWhere(
        (item) => item.name == itemName,
        orElse: () => ClothingItem(
          name: itemName,
        ), // Return item without image if not found
      );
      return item;
    }
    // Return item without image if category not found
    return ClothingItem(name: itemName);
  }

  // Add or update a clothing item (for MongoDB sync)
  void updateClothingItem(String category, ClothingItem item) {
    if (!_clothingDatabase.containsKey(category)) {
      _clothingDatabase[category] = [];
    }

    final index = _clothingDatabase[category]!.indexWhere(
      (i) => i.name == item.name,
    );
    if (index >= 0) {
      _clothingDatabase[category]![index] = item;
    } else {
      _clothingDatabase[category]!.add(item);
    }
    notifyListeners();
  }

  // -------------------
  // Navigation
  // -------------------
  void setNavigationIndex(int index) {
    print(
      '[USER] setNavigationIndex: from $_navigationIndex -> $index '
      '(isProfileComplete=$isProfileComplete, bodyType=$bodyType)',
    );
    if (_navigationIndex == index) return;
    _navigationIndex = index;
    notifyListeners();
  }

  // -------------------
  // Completeness Checks
  // -------------------
  bool get isBodyTypeComplete => bodyType != null && bodyType!.isNotEmpty;
  bool get isSkinToneComplete =>
      skinUndertone != null && skinUndertone!.isNotEmpty;
  bool get isGenderComplete => gender != null && gender!.isNotEmpty;
  bool get isProfileComplete =>
      isBodyTypeComplete && isSkinToneComplete && isGenderComplete;

  // -------------------
  // Updaters
  // -------------------
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

    // Save to MongoDB
    await AuthService.updateProfile({'bodyType': type});
  }

  Future<void> updateSkinTone(String tone) async {
    skinUndertone = tone;
    notifyListeners();

    // Save to MongoDB
    await AuthService.updateProfile({'skinUndertone': tone});
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
    }
  }

  void setSkinUndertone(String tone) => updateSkinTone(tone);

  // -------------------
  // Color Palette
  // -------------------
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

  // -------------------
  // Helper: Get undertone-appropriate colors
  // -------------------
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

  // -------------------
  // Style Tips (separate from clothing items)
  // -------------------
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

  // -------------------
  // INTEGRATED Recommendation System
  // -------------------
  Map<String, List<String>> get styleRecommendations {
    if (!isProfileComplete) {
      return {
        "General": ["Please complete your profile for full recommendations."],
      };
    }

    final recs = <String, List<String>>{};
    final tone = skinUndertone?.toLowerCase() ?? "neutral";
    final isMale = gender?.toLowerCase() == "male";
    final isFemale = gender?.toLowerCase() == "female";

    // -------------------
    // 2. EXPANDED Gender-Specific Categorized Clothing
    // -------------------

    // SWEATERS & KNITS - Unisex
    recs["Sweaters & Knits"] = tone == "warm"
        ? [
            "Mustard yellow sweater",
            "Olive green sweater",
            "Terracotta sweater",
            "Burnt orange knit",
            "Caramel turtleneck",
            "Rust cable knit",
            "Warm beige cardigan",
            "Cinnamon crewneck",
          ]
        : tone == "cool"
        ? [
            "Teal sweater",
            "Navy blue sweater",
            "Lavender knit",
            "Charcoal turtleneck",
            "Berry cardigan",
            "Slate blue crewneck",
            "Ice gray sweater",
            "Emerald green knit",
          ]
        : [
            "Soft taupe sweater",
            "Denim blue sweater",
            "Oatmeal knit",
            "Heather gray cardigan",
            "Sage green sweater",
            "Mushroom crewneck",
            "Stone turtleneck",
          ];

    // SHIRTS - Unisex
    recs["Shirts"] = tone == "warm"
        ? [
            "Camel button-down",
            "Warm red polo",
            "Peach oxford shirt",
            "Golden yellow shirt",
            "Coral linen shirt",
            "Rust chambray",
            "Honey flannel",
            "Cream dress shirt",
          ]
        : tone == "cool"
        ? [
            "Icy blue oxford",
            "Navy polo",
            "Periwinkle dress shirt",
            "Teal chambray",
            "Slate linen shirt",
            "Royal blue button-down",
            "Mint green shirt",
            "Crisp white shirt",
          ]
        : [
            "Classic white shirt",
            "Soft gray oxford",
            "Sage green linen",
            "Dusty rose polo",
            "Beige dress shirt",
            "Heather gray flannel",
            "Stone chambray",
          ];

    // T-SHIRTS & CASUAL TOPS - Unisex
    recs["T-Shirts & Casual Tops"] = tone == "warm"
        ? [
            "Warm ivory tee",
            "Terracotta graphic tee",
            "Olive henley",
            "Burnt sienna polo",
            "Camel basic tee",
            "Mustard long-sleeve",
          ]
        : tone == "cool"
        ? [
            "Navy striped tee",
            "Berry henley",
            "Teal graphic tee",
            "Lavender polo",
            "Charcoal basic tee",
            "Icy blue long-sleeve",
          ]
        : [
            "Heather gray tee",
            "Soft taupe henley",
            "Oatmeal basic tee",
            "Sage striped tee",
            "Denim blue polo",
          ];

    // BLOUSES & TOPS - Female only
    if (isFemale) {
      recs["Blouses & Tops"] = tone == "warm"
          ? [
              "Warm ivory blouse",
              "Coral silk blouse",
              "Peach off-shoulder top",
              "Golden yellow peplum top",
              "Terracotta wrap top",
              "Honey ruffled blouse",
              "Rust boat neck top",
              "Camel halter top",
            ]
          : tone == "cool"
          ? [
              "Crisp white blouse",
              "Lavender silk blouse",
              "Berry peplum top",
              "Periwinkle off-shoulder top",
              "Teal wrap top",
              "Sapphire ruffled blouse",
              "Navy boat neck top",
              "Emerald halter top",
            ]
          : [
              "Off-white blouse",
              "Dusty rose silk blouse",
              "Heather gray peplum top",
              "Sage off-shoulder top",
              "Blush beige wrap top",
              "Soft taupe ruffled blouse",
              "Stone boat neck top",
            ];
    }

    // TROUSERS & PANTS - Unisex
    recs["Trousers & Pants"] = tone == "warm"
        ? [
            "Camel trousers",
            "Rust chinos",
            "Terracotta dress pants",
            "Olive cargo pants",
            "Brown corduroy pants",
            "Tan wide-leg trousers",
            "Cognac leather pants",
            "Warm beige slacks",
          ]
        : tone == "cool"
        ? [
            "Charcoal trousers",
            "Slate chinos",
            "Navy dress pants",
            "Teal cargo pants",
            "Black corduroy pants",
            "Gray wide-leg trousers",
            "Plum leather pants",
            "Cool gray slacks",
          ]
        : [
            "Taupe trousers",
            "Beige chinos",
            "Stone dress pants",
            "Sage cargo pants",
            "Mushroom corduroy pants",
            "Greige wide-leg trousers",
            "Denim slacks",
          ];

    // JEANS & DENIM - Unisex
    recs["Jeans & Denim"] = tone == "warm"
        ? [
            "Warm wash denim jeans",
            "Golden brown jeans",
            "Rust denim",
            "Camel colored jeans",
            "Tobacco brown jeans",
          ]
        : tone == "cool"
        ? [
            "Cool wash denim jeans",
            "Dark indigo jeans",
            "Black jeans",
            "Gray denim",
            "Navy blue jeans",
          ]
        : [
            "Medium wash denim jeans",
            "Stone washed jeans",
            "Beige jeans",
            "Gray-blue denim",
          ];

    // SHORTS - Unisex
    recs["Shorts"] = tone == "warm"
        ? [
            "Terracotta shorts",
            "Camel chino shorts",
            "Rust bermuda shorts",
            "Olive cargo shorts",
          ]
        : tone == "cool"
        ? [
            "Teal shorts",
            "Navy chino shorts",
            "Charcoal bermuda shorts",
            "Slate cargo shorts",
          ]
        : [
            "Denim shorts",
            "Beige chino shorts",
            "Stone bermuda shorts",
            "Sage cargo shorts",
          ];

    // SKIRTS - Female only
    if (isFemale) {
      recs["Skirts"] = tone == "warm"
          ? [
              "Terracotta A-line skirt",
              "Camel pencil skirt",
              "Honey pleated skirt",
              "Rust midi skirt",
              "Bronze maxi skirt",
              "Coral wrap skirt",
              "Warm beige high-waist skirt",
            ]
          : tone == "cool"
          ? [
              "Navy A-line skirt",
              "Charcoal pencil skirt",
              "Berry pleated skirt",
              "Teal midi skirt",
              "Emerald maxi skirt",
              "Sapphire wrap skirt",
              "Cool gray high-waist skirt",
            ]
          : [
              "Stone A-line skirt",
              "Taupe pencil skirt",
              "Sage pleated skirt",
              "Blush beige midi skirt",
              "Mushroom maxi skirt",
              "Dusty rose wrap skirt",
              "Heather gray high-waist skirt",
            ];
    }

    // DRESSES - Female only
    if (isFemale) {
      recs["Dresses"] = tone == "warm"
          ? [
              "Coral wrap dress",
              "Honey maxi dress",
              "Bronze evening gown",
              "Terracotta midi dress",
              "Peach sundress",
              "Rust bodycon dress",
              "Golden yellow shift dress",
              "Camel shirt dress",
              "Warm ivory cocktail dress",
              "Burnt orange fit-and-flare dress",
            ]
          : tone == "cool"
          ? [
              "Sapphire day dress",
              "Teal maxi dress",
              "Emerald evening gown",
              "Navy midi dress",
              "Lavender sundress",
              "Berry bodycon dress",
              "Periwinkle shift dress",
              "Charcoal shirt dress",
              "Crisp white cocktail dress",
              "Royal blue fit-and-flare dress",
            ]
          : [
              "Blush beige dress",
              "Muted navy maxi dress",
              "Classic black evening gown",
              "Stone midi dress",
              "Dusty rose sundress",
              "Sage bodycon dress",
              "Heather gray shift dress",
              "Taupe shirt dress",
              "Off-white cocktail dress",
              "Mushroom fit-and-flare dress",
            ];
    }

    // JUMPSUITS & ROMPERS - Female only
    if (isFemale) {
      recs["Jumpsuits & Rompers"] = tone == "warm"
          ? [
              "Terracotta jumpsuit",
              "Camel wide-leg jumpsuit",
              "Coral romper",
              "Rust culotte jumpsuit",
            ]
          : tone == "cool"
          ? [
              "Navy jumpsuit",
              "Teal wide-leg jumpsuit",
              "Lavender romper",
              "Emerald culotte jumpsuit",
            ]
          : [
              "Stone jumpsuit",
              "Beige wide-leg jumpsuit",
              "Dusty rose romper",
              "Sage culotte jumpsuit",
            ];
    }

    // BLAZERS & JACKETS - Unisex
    recs["Blazers & Jackets"] = tone == "warm"
        ? [
            "Camel blazer",
            "Brown leather jacket",
            "Rust corduroy jacket",
            "Olive utility jacket",
            "Tan bomber jacket",
            "Cognac suede jacket",
            "Terracotta denim jacket",
            "Warm tweed blazer",
          ]
        : tone == "cool"
        ? [
            "Charcoal blazer",
            "Black leather jacket",
            "Navy corduroy jacket",
            "Teal utility jacket",
            "Slate bomber jacket",
            "Plum suede jacket",
            "Indigo denim jacket",
            "Cool gray tweed blazer",
          ]
        : [
            "Gray blazer",
            "Beige leather jacket",
            "Stone corduroy jacket",
            "Sage utility jacket",
            "Taupe bomber jacket",
            "Mushroom suede jacket",
            "Medium wash denim jacket",
            "Heather tweed blazer",
          ];

    // COATS - Unisex
    recs["Coats"] = tone == "warm"
        ? [
            "Camel overcoat",
            "Olive parka",
            "Tan trench coat",
            "Brown wool coat",
            "Rust peacoat",
            "Cognac long coat",
          ]
        : tone == "cool"
        ? [
            "Charcoal overcoat",
            "Navy parka",
            "Black trench coat",
            "Slate wool coat",
            "Plum peacoat",
            "Cool gray long coat",
          ]
        : [
            "Stone trench coat",
            "Beige wool coat",
            "Gray overcoat",
            "Taupe parka",
            "Mushroom peacoat",
            "Heather long coat",
          ];

    // SHOES - Unisex
    recs["Shoes"] = tone == "warm"
        ? [
            "Cognac loafers",
            "Tan ankle boots",
            "Brown oxford shoes",
            "Camel sneakers",
            "Rust chelsea boots",
            "Golden sandals",
            "Tobacco leather shoes",
          ]
        : tone == "cool"
        ? [
            "Black dress shoes",
            "Navy sneakers",
            "Charcoal ankle boots",
            "Slate oxford shoes",
            "Plum chelsea boots",
            "Silver sandals",
            "Cool gray leather shoes",
          ]
        : [
            "Taupe loafers",
            "Gray boots",
            "Beige sneakers",
            "Stone oxford shoes",
            "Mushroom chelsea boots",
            "Nude sandals",
            "Greige leather shoes",
          ];

    // BAGS & ACCESSORIES - Gender-specific
    if (isFemale) {
      recs["Bags & Accessories"] = tone == "warm"
          ? [
              "Tan leather handbag",
              "Gold jewelry",
              "Cognac crossbody bag",
              "Camel tote bag",
              "Bronze clutch",
              "Warm beige shoulder bag",
              "Copper accessories",
              "Rust bucket bag",
            ]
          : tone == "cool"
          ? [
              "Navy handbag",
              "Silver jewelry",
              "Black crossbody bag",
              "Charcoal tote bag",
              "Plum clutch",
              "Cool gray shoulder bag",
              "Platinum accessories",
              "Emerald bucket bag",
            ]
          : [
              "Beige handbag",
              "Rose gold jewelry",
              "Taupe crossbody bag",
              "Stone tote bag",
              "Mushroom clutch",
              "Heather gray shoulder bag",
              "Mixed metal accessories",
              "Sage bucket bag",
            ];
    } else if (isMale) {
      recs["Bags & Accessories"] = tone == "warm"
          ? [
              "Gold watch",
              "Brown leather belt",
              "Tan wallet",
              "Cognac messenger bag",
              "Camel backpack",
              "Bronze cufflinks",
              "Warm leather bracelet",
            ]
          : tone == "cool"
          ? [
              "Silver watch",
              "Black leather belt",
              "Navy wallet",
              "Charcoal messenger bag",
              "Slate backpack",
              "Platinum cufflinks",
              "Cool leather bracelet",
            ]
          : [
              "Steel watch",
              "Gray leather belt",
              "Brown wallet",
              "Stone messenger bag",
              "Beige backpack",
              "Mixed metal cufflinks",
              "Neutral leather bracelet",
            ];
    }

    // SCARVES & TIES - Unisex
    recs["Scarves & Ties"] = tone == "warm"
        ? [
            "Camel scarf",
            "Rust silk tie",
            "Terracotta necktie",
            "Olive patterned scarf",
            "Gold accent tie",
          ]
        : tone == "cool"
        ? [
            "Navy scarf",
            "Charcoal silk tie",
            "Berry necktie",
            "Teal patterned scarf",
            "Silver accent tie",
          ]
        : [
            "Stone scarf",
            "Gray silk tie",
            "Sage necktie",
            "Taupe patterned scarf",
            "Rose gold accent tie",
          ];

    // -------------------
    // 3. Personalized Outfit Combinations
    // -------------------
    if (isFemale) {
      // Hourglass
      if (bodyType?.toLowerCase() == "hourglass" && tone == "warm") {
        recs["Personalized Outfit"] = [
          "Coral wrap dress + Camel blazer + Gold jewelry + Cognac loafers + Tan handbag",
        ];
      } else if (bodyType?.toLowerCase() == "hourglass" && tone == "cool") {
        recs["Personalized Outfit"] = [
          "Sapphire wrap dress + Charcoal blazer + Silver jewelry + Black dress shoes + Navy handbag",
        ];
      } else if (bodyType?.toLowerCase() == "hourglass" && tone == "neutral") {
        recs["Personalized Outfit"] = [
          "Blush beige wrap dress + Stone trench coat + Rose gold jewelry + Nude sandals + Beige handbag",
        ];
      }
      // Pear/Triangle
      else if ((bodyType?.toLowerCase() == "pear" ||
              bodyType?.toLowerCase() == "triangle") &&
          tone == "warm") {
        recs["Personalized Outfit"] = [
          "Peach off-shoulder top + Warm wash denim jeans + Copper accessories + Cognac loafers + Camel tote bag",
        ];
      } else if ((bodyType?.toLowerCase() == "pear" ||
              bodyType?.toLowerCase() == "triangle") &&
          tone == "cool") {
        recs["Personalized Outfit"] = [
          "Periwinkle off-shoulder top + Dark indigo jeans + Silver jewelry + Black dress shoes + Charcoal tote bag",
        ];
      } else if ((bodyType?.toLowerCase() == "pear" ||
              bodyType?.toLowerCase() == "triangle") &&
          tone == "neutral") {
        recs["Personalized Outfit"] = [
          "Heather gray off-shoulder top + Medium wash denim jeans + Rose gold jewelry + Nude sandals + Taupe tote bag",
        ];
      }
      // Inverted Triangle
      else if (bodyType?.toLowerCase() == "inverted triangle" &&
          tone == "warm") {
        recs["Personalized Outfit"] = [
          "Rust V-neck top + Tan wide-leg trousers + Honey pleated skirt + Gold jewelry + Tan ankle boots",
        ];
      } else if (bodyType?.toLowerCase() == "inverted triangle" &&
          tone == "cool") {
        recs["Personalized Outfit"] = [
          "Navy V-neck top + Gray wide-leg trousers + Berry pleated skirt + Silver jewelry + Navy sneakers",
        ];
      } else if (bodyType?.toLowerCase() == "inverted triangle" &&
          tone == "neutral") {
        recs["Personalized Outfit"] = [
          "Stone V-neck top + Greige wide-leg trousers + Sage pleated skirt + Rose gold jewelry + Taupe loafers",
        ];
      }
      // Rectangle
      else if (bodyType?.toLowerCase() == "rectangle" && tone == "warm") {
        recs["Personalized Outfit"] = [
          "Golden yellow peplum top + Honey maxi dress + Gold jewelry + Cognac chelsea boots + Warm beige shoulder bag",
        ];
      } else if (bodyType?.toLowerCase() == "rectangle" && tone == "cool") {
        recs["Personalized Outfit"] = [
          "Berry peplum top + Sapphire day dress + Silver jewelry + Charcoal ankle boots + Cool gray shoulder bag",
        ];
      } else if (bodyType?.toLowerCase() == "rectangle" && tone == "neutral") {
        recs["Personalized Outfit"] = [
          "Heather gray peplum top + Muted navy maxi dress + Rose gold jewelry + Gray boots + Heather gray shoulder bag",
        ];
      }
      // Apple/Oval
      else if ((bodyType?.toLowerCase() == "apple" ||
              bodyType?.toLowerCase() == "oval") &&
          tone == "warm") {
        recs["Personalized Outfit"] = [
          "Rust V-neck top + Terracotta midi dress + Camel trousers + Gold jewelry + Golden sandals",
        ];
      } else if ((bodyType?.toLowerCase() == "apple" ||
              bodyType?.toLowerCase() == "oval") &&
          tone == "cool") {
        recs["Personalized Outfit"] = [
          "Navy V-neck top + Emerald evening gown + Charcoal trousers + Silver jewelry + Silver sandals",
        ];
      } else if ((bodyType?.toLowerCase() == "apple" ||
              bodyType?.toLowerCase() == "oval") &&
          tone == "neutral") {
        recs["Personalized Outfit"] = [
          "Stone V-neck top + Sage bodycon dress + Beige trousers + Rose gold jewelry + Nude sandals",
        ];
      }
    } else if (isMale) {
      // Mesomorph
      if (bodyType?.toLowerCase() == "mesomorph" && tone == "cool") {
        recs["Personalized Outfit"] = [
          "Navy polo + Charcoal trousers + Black leather jacket + Silver watch + Black leather belt",
        ];
      } else if (bodyType?.toLowerCase() == "mesomorph" && tone == "warm") {
        recs["Personalized Outfit"] = [
          "Warm red polo + Rust chinos + Brown leather jacket + Gold watch + Brown leather belt",
        ];
      } else if (bodyType?.toLowerCase() == "mesomorph" && tone == "neutral") {
        recs["Personalized Outfit"] = [
          "Classic white shirt + Beige chinos + Gray blazer + Steel watch + Gray leather belt",
        ];
      }
      // Ectomorph
      else if (bodyType?.toLowerCase() == "ectomorph" && tone == "warm") {
        recs["Personalized Outfit"] = [
          "Olive sweater + Honey flannel + Camel blazer + Brown oxford shoes + Cognac messenger bag",
        ];
      } else if (bodyType?.toLowerCase() == "ectomorph" && tone == "cool") {
        recs["Personalized Outfit"] = [
          "Navy sweater + Icy blue oxford + Charcoal blazer + Black dress shoes + Slate backpack",
        ];
      } else if (bodyType?.toLowerCase() == "ectomorph" && tone == "neutral") {
        recs["Personalized Outfit"] = [
          "Denim sweater + Beige dress shirt + Gray blazer + Beige sneakers + Stone messenger bag",
        ];
      }
      // Endomorph
      else if (bodyType?.toLowerCase() == "endomorph" && tone == "warm") {
        recs["Personalized Outfit"] = [
          "Olive cargo pants + Brown wool coat + Camel trousers + Tan ankle boots + Camel backpack",
        ];
      } else if (bodyType?.toLowerCase() == "endomorph" && tone == "cool") {
        recs["Personalized Outfit"] = [
          "Navy dress pants + Black trench coat + Charcoal trousers + Black dress shoes + Charcoal messenger bag",
        ];
      } else if (bodyType?.toLowerCase() == "endomorph" && tone == "neutral") {
        recs["Personalized Outfit"] = [
          "Stone dress pants + Gray overcoat + Taupe trousers + Gray boots + Stone messenger bag",
        ];
      }
    }

    return recs;
  }
}
