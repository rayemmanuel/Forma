import fs from "fs";

// Step 1: Read the URLs from urls.txt
const rawData = fs.readFileSync("./urls.txt", "utf-8");

// Split lines and remove empty ones
const urls = rawData.split("\n").map(line => line.trim()).filter(Boolean);

// Step 2: Convert each URL into an object with flexible attributes
const updatedImages = urls.map((url, index) => ({
  id: index + 1,
  CloudinaryURL: url,
  color_family: "",
  style_type: "",
  fit_balance: "",
  fabric_type: "",
  texture: "",
  season: ""
}));

// Step 3: Save as JSON file
fs.writeFileSync("./images_updated.json", JSON.stringify(updatedImages, null, 2));

console.log(`✅ Processed ${updatedImages.length} image URLs.`);
console.log("💾 New file saved as images_updated.json");

