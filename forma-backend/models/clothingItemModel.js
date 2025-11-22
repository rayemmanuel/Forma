import mongoose from 'mongoose';

const clothingItemSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  category: {
    type: String,
    required: true,
  },
  url: {
    type: String,
    required: true,
  },
}, {
  // ✅ THIS IS THE FIX:
  // Explicitly tell Mongoose which collection to use.
  collection: 'clothingitems' // ❗️REPLACE 'clothingitems' with the name you found in Step 1
});

const ClothingItem = mongoose.model('ClothingItem', clothingItemSchema);

export default ClothingItem;