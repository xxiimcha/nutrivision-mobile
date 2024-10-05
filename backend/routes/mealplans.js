const express = require('express');
const router = express.Router();
const MealPlan = require('../models/MealPlan');

// Create a new meal plan
router.post('/', async (req, res) => {
  try {
    const newMealPlan = new MealPlan(req.body);
    const savedMealPlan = await newMealPlan.save();
    res.status(201).json(savedMealPlan);
  } catch (error) {
    console.error('Error creating meal plan:', error);
    res.status(500).json({ message: 'Error creating meal plan', error });
  }
});

// Get meal plan for a specific patient by week
router.get('/:patientId/:week', async (req, res) => {
  try {
    const { patientId, week } = req.params;

    // Validate and format the week (e.g., 'yyyy-MM-dd')
    const weekStart = new Date(week);
    if (isNaN(weekStart.getTime())) {
      return res.status(400).json({ message: 'Invalid week format. Please use yyyy-MM-dd.' });
    }

    // Find the meal plan for the specified patient and week
    const mealPlan = await MealPlan.findOne({ patientId, week });

    // If no meal plan found, return a default empty meal plan structure
    if (!mealPlan) {
      const emptyMealPlan = {
        patientId,
        week,
        Monday: {
          breakfast: { mainDish: 'N/A', drinks: 'N/A', vitamins: 'N/A', approved: false },
          lunch: { mainDish: 'N/A', drinks: 'N/A', vitamins: 'N/A', approved: false },
          dinner: { mainDish: 'N/A', drinks: 'N/A', vitamins: 'N/A', approved: false },
        },
        Tuesday: { /* similar structure */ },
        Wednesday: { /* similar structure */ },
        Thursday: { /* similar structure */ },
        Friday: { /* similar structure */ },
        Saturday: { /* similar structure */ },
        Sunday: { /* similar structure */ }
      };

      return res.status(200).json(emptyMealPlan);  // Return the empty structure for the week
    }

    // If meal plan exists, return the found meal plan
    res.status(200).json(mealPlan);
  } catch (error) {
    console.error(`Error fetching meal plan for patient ${req.params.patientId}:`, error);
    res.status(500).json({ message: 'Error fetching meal plan', error });
  }
});

// Update a meal plan by patientId and week
router.put('/:patientId/:week', async (req, res) => {
  try {
    const { patientId, week } = req.params;
    const updatedMealPlan = await MealPlan.findOneAndUpdate(
      { patientId, week },
      req.body,
      { new: true, runValidators: true }
    );

    if (!updatedMealPlan) {
      return res.status(404).json({ message: 'Meal plan not found' });
    }

    res.status(200).json(updatedMealPlan);
  } catch (error) {
    console.error(`Error updating meal plan for patient ${req.params.patientId}:`, error);
    res.status(500).json({ message: 'Error updating meal plan', error });
  }
});

// Get all meal plans for a specific user
router.get('/:patientId', async (req, res) => {
  try {
    const { patientId } = req.params;
    const mealPlans = await MealPlan.find({ patientId });

    if (mealPlans.length === 0) {
      return res.status(404).json({ message: 'No meal plans found for this patient' });
    }

    res.status(200).json(mealPlans);
  } catch (error) {
    console.error(`Error fetching meal plans for patient ${req.params.patientId}:`, error);
    res.status(500).json({ message: 'Error fetching meal plans', error });
  }
});

module.exports = router;
