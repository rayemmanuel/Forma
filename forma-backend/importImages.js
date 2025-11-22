import fs from 'fs'; // Use the standard fs for streams
import csv from 'csv-parser';
import { MongoClient } from 'mongodb';
import { fileURLToPath } from 'url';
import { dirname, resolve } from 'path';

const MONGO_URI = "mongodb+srv://forma_admin:forma_admin123@cluster0.g5gtq4d.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";
const DB_NAME = "FORMA";
// IMPORTANT: Make sure this matches your Mongoose model's collection name ('clothingitems')
const COLLECTION_NAME = "clothingitems"; 

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const CSV_PATH = resolve(__dirname, '../data.csv');

async function importData() {
  const client = new MongoClient(MONGO_URI);
  try {
    await client.connect();
    console.log("Connected to MongoDB...");
    const collection = client.db(DB_NAME).collection(COLLECTION_NAME);

    const itemsToInsert = [];
    fs.createReadStream(CSV_PATH)
      .pipe(csv())
      .on('data', (row) => {
        // This runs for each row in your CSV file
        itemsToInsert.push({
          name: row.name,
          category: row.category,
          url: row.url,
        });
      })
      .on('end', async () => {
        // This runs after all rows have been read
        if (itemsToInsert.length > 0) {
          console.log(`Read ${itemsToInsert.length} items from CSV. Inserting into database...`);
          await collection.insertMany(itemsToInsert);
          console.log(`✅ Successfully inserted ${itemsToInsert.length} items.`);
        } else {
          console.log("No items found in CSV to insert.");
        }
        await client.close();
        console.log("Disconnected from MongoDB.");
      });
  } catch (err) {
    console.error("❌ Error during import:", err);
    await client.close();
  }
}

importData();