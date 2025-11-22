import express from 'express';
import ClothingItem from '../models/clothingItemModel.js';
import { getRecommendationNames } from '../utils/recommendationLogic.js';

const router = express.Router();

router.get('/', async (req, res) => {
  try {
    const { gender, bodyType, skinUndertone } = req.query;

    if (!gender || !bodyType || !skinUndertone) {
      return res.status(400).json({ message: 'Missing profile information' });
    }
    
    // 1. Get the list of recommended clothing names from your logic file
    const recommendationMap = getRecommendationNames(gender, skinUndertone);
    const allNames = Object.values(recommendationMap).flat();

    // 2. Create a case-insensitive search query
    const nameRegexes = allNames.map(name => new RegExp(`^${name.trim()}$`, "i"));

    // 3. Find all items in the database that match the names
    const clothingItemsFromDB = await ClothingItem.find({ name: { $in: nameRegexes } });

    // 4. Group the found items by their category
    const finalRecommendations = {};
    for (const item of clothingItemsFromDB) {
      if (!finalRecommendations[item.category]) {
        finalRecommendations[item.category] = [];
      }
      finalRecommendations[item.category].push(item);
    }

    // 5. Send the final grouped data back to the app
    res.json(finalRecommendations);

  } catch (error) {
    console.error('Error fetching recommendations:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

export default router;