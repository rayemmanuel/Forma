// forma-backend/routes/recommendationRoutes.js
import express from 'express';
import ClothingItem from '../models/clothingItemModel.js'; // Make sure this path is correct
import { getRecommendationNames } from '../utils/recommendationLogic.js'; // We will create this file

const router = express.Router();

// @desc   Get clothing recommendations based on user profile
// @route  GET /api/recommendations
router.get('/', async (req, res) => {
  try {
    const { gender, bodyType, skinUndertone } = req.query;

    if (!gender || !bodyType || !skinUndertone) {
      return res.status(400).json({ message: 'Missing profile information' });
    }
    
    // 1. Get the list of recommended clothing NAMES from the logic file
    const recommendationMap = getRecommendationNames(gender, skinUndertone);
    
    // 2. Fetch all clothing items from the database that match those names
    const allNames = Object.values(recommendationMap).flat(); // Get all names in a single array
    const clothingItemsFromDB = await ClothingItem.find({ name: { $in: allNames } });

    // 3. Group the fetched items by category
    const finalRecommendations = {};
    for (const item of clothingItemsFromDB) {
      if (!finalRecommendations[item.category]) {
        finalRecommendations[item.category] = [];
      }
      finalRecommendations[item.category].push(item);
    }

    res.json(finalRecommendations);

  } catch (error) {
    console.error('Error fetching recommendations:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

export default router;