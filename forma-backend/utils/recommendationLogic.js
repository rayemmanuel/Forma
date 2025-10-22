// forma-backend/utils/recommendationLogic.js

// This function replicates the logic from your old Dart file
export function getRecommendationNames(gender, skinUndertone) {
  const isFemale = gender.toLowerCase() === 'female';
  const tone = skinUndertone.toLowerCase();
  
  const recs = {};

  // SWEATERS & KNITS
  recs["Sweaters & Knits"] = tone === "warm"
    ? ["Mustard yellow sweater", "Olive green sweater", "Terracotta sweater", "Burnt orange knit", "Caramel turtleneck", "Rust cable knit", "Warm beige cardigan", "Cinnamon crewneck"]
    : tone === "cool"
    ? ["Teal sweater", "Navy blue sweater", "Lavender knit", "Charcoal turtleneck", "Berry cardigan", "Slate blue crewneck", "Ice gray sweater", "Emerald green knit"]
    : ["Soft taupe sweater", "Denim blue sweater", "Oatmeal knit", "Heather gray cardigan", "Sage green sweater", "Mushroom crewneck", "Stone turtleneck"];

  // SHIRTS
  recs["Shirts"] = tone === "warm"
    ? ["Camel button-down", "Warm red polo", "Peach oxford shirt", "Golden yellow shirt", "Coral linen shirt", "Rust chambray", "Honey flannel", "Cream dress shirt"]
    : tone === "cool"
    ? ["Icy blue oxford", "Navy polo", "Periwinkle dress shirt", "Teal chambray", "Slate linen shirt", "Royal blue button-down", "Mint green shirt", "Crisp white shirt"]
    : ["Classic white shirt", "Soft gray oxford", "Sage green linen", "Dusty rose polo", "Beige dress shirt", "Heather gray flannel", "Stone chambray"];
  
  // Add all other categories here (T-Shirts, Pants, Shoes, etc.) following the same pattern...

  if (isFemale) {
    // DRESSES
    recs["Dresses"] = tone === "warm"
      ? ["Coral wrap dress", "Honey maxi dress", "Bronze evening gown", "Terracotta midi dress", "Peach sundress", "Rust bodycon dress", "Golden yellow shift dress", "Camel shirt dress", "Warm ivory cocktail dress", "Burnt orange fit-and-flare dress"]
      : tone === "cool"
      ? ["Sapphire day dress", "Teal maxi dress", "Emerald evening gown", "Navy midi dress", "Lavender sundress", "Berry bodycon dress", "Periwinkle shift dress", "Charcoal shirt dress", "Crisp white cocktail dress", "Royal blue fit-and-flare dress"]
      : ["Blush beige dress", "Muted navy maxi dress", "Classic black evening gown", "Stone midi dress", "Dusty rose sundress", "Sage bodycon dress", "Heather gray shift dress", "Taupe shirt dress", "Off-white cocktail dress", "Mushroom fit-and-flare dress"];
    
    // Add other female-specific categories (Skirts, Blouses, etc.)
  }

  return recs;
}