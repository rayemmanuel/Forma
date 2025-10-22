import fs from 'fs/promises'; // Use promises API for async/await
import { MongoClient } from 'mongodb';
import { fileURLToPath } from 'url'; // For robust paths
import { dirname, resolve } from 'path'; // For robust paths

// ===== CONFIG =====
const MONGO_URI = "mongodb+srv://forma_admin:forma_admin123@cluster0.g5gtq4d.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";
const DB_NAME = "FORMA";
const COLLECTION_NAME = "forma_images";

// --- Robust Path Handling ---
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// ❗️❗️ IMPORTANT ❗️❗️
// Make this path point to your TEXT FILE with the URLs, not images.json
const IMAGE_JSON_PATH = resolve(__dirname, '../urls.txt'); // <-- e.g., '../urls.txt'
// ==================

/**
 * Connects to MongoDB and saves an array of image URLs.
 * Skips any URLs that already exist in the collection.
 */
async function saveImagesToMongo(images) {
  const client = new MongoClient(MONGO_URI);
  console.log("Connecting to MongoDB...");

  try {
    await client.connect();
    console.log("Connected successfully.");
    const db = client.db(DB_NAME);
    const collection = db.collection(COLLECTION_NAME);

    let insertedCount = 0;
    let skippedCount = 0;

    for (const img of images) {
      // The 'img' is just a string (a URL) from our text file
      const url = img;

      if (!url) {
        console.warn("⚠️ Skipped empty line.");
        continue;
      }

      // Skip duplicates
      const exists = await collection.findOne({ url });
      if (!exists) {
        await collection.insertOne({ url });
        console.log(`✅ Inserted: ${url}`);
        insertedCount++;
      } else {
        console.log(`⚠️ Skipped duplicate: ${url}`);
        skippedCount++;
      }
    }
    console.log(`\n--- Summary ---`);
    console.log(`👍 Inserted: ${insertedCount}`);
    console.log(`👌 Skipped:   ${skippedCount}`);
    console.log(`----------------`);

  } catch (err) {
    console.error("❌ Error inserting images:", err);
  } finally {
    await client.close();
    console.log("Disconnected from MongoDB.");
  }
}

// --- Main Execution ---
(async () => {
  try {
    // 1️⃣ Read and parse the URL file (now async)
    console.log(`Reading file from: ${IMAGE_JSON_PATH}`);
    const rawData = await fs.readFile(IMAGE_JSON_PATH, "utf-8");

    // ADD THESE 3 LINES FOR DEBUGGING
    console.log("--- RAW FILE CONTENT ---");
    console.log(rawData);
    console.log("------------------------");

    // --- This is the parsing logic for a PLAIN TEXT file ---
    const data = rawData
      .split(/[,\n]/)       // Split by comma or newline
      .map(url => url.trim()) // Remove extra spaces
      .filter(url => url.startsWith('http')); // Keep only valid URLs
    // --------------------------------------------------------

    console.log(`✅ Found ${data.length} images in the file`);
    if (data.length > 0) {
      console.log('Here are the first 5 images:');
      console.log(data.slice(0, 5));
    }

    // 2️⃣ Insert images into MongoDB (now properly awaited)
    await saveImagesToMongo(data);

    console.log("\n✅ Script finished successfully.");

  } catch (err) {
    console.error('❌ Error during script execution:', err);
    process.exit(1); // Exit with an error code
  }
})();