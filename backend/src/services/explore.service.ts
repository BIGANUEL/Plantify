import { ExplorePlant, IExplorePlant } from '../models/ExplorePlant.model';
import { Problem, IProblem } from '../models/Problem.model';

export class ExploreService {
  /**
   * Get all active plants in the catalog
   */
  async getExplorePlants(category?: string, search?: string): Promise<IExplorePlant[]> {
    let query: any = { isActive: true };

    if (category && category !== 'All') {
      query.category = category;
    }

    if (search && search.trim()) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { scientificName: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
        { tags: { $in: [new RegExp(search, 'i')] } },
      ];
    }

    return ExplorePlant.find(query).sort({ name: 1 }).exec();
  }

  /**
   * Get a specific explore plant by ID
   */
  async getExplorePlantById(plantId: string): Promise<IExplorePlant | null> {
    return ExplorePlant.findOne({
      _id: plantId,
      isActive: true,
    }).exec();
  }

  /**
   * Get all active problems
   */
  async getProblems(category?: string, search?: string): Promise<IProblem[]> {
    let query: any = { isActive: true };

    if (category && category !== 'All') {
      query.category = category;
    }

    if (search && search.trim()) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
        { category: { $regex: search, $options: 'i' } },
        { commonCauses: { $in: [new RegExp(search, 'i')] } },
        { solutions: { $in: [new RegExp(search, 'i')] } },
      ];
    }

    return Problem.find(query).sort({ name: 1 }).exec();
  }

  /**
   * Get a specific problem by ID
   */
  async getProblemById(problemId: string): Promise<IProblem | null> {
    return Problem.findOne({
      _id: problemId,
      isActive: true,
    }).exec();
  }

  /**
   * Seed initial explore plants data (can be called once or via admin endpoint)
   */
  async seedExplorePlants(): Promise<void> {
    const count = await ExplorePlant.countDocuments();
    if (count > 0) {
      return; // Already seeded
    }

    const defaultPlants = [
      // Indoor category (2 plants)
      {
        name: 'Monstera',
        scientificName: 'Monstera deliciosa',
        category: 'Indoor',
        difficulty: 'Moderate',
        light: 'Bright Indirect',
        water: 'Medium',
        tags: ['Statement Plant', 'Climbing', 'Popular'],
        description: 'Iconic split-leaf plant. Prefers bright, indirect light.',
        icon: 'eco_rounded',
      },
      {
        name: 'Fiddle Leaf Fig',
        scientificName: 'Ficus lyrata',
        category: 'Indoor',
        difficulty: 'Moderate',
        light: 'Bright Indirect',
        water: 'Medium',
        tags: ['Statement Plant', 'Trendy', 'Large Leaves'],
        description: 'Popular statement plant. Requires consistent care.',
        icon: 'forest_rounded',
      },
      // Outdoor category (2 plants)
      {
        name: 'Lavender',
        scientificName: 'Lavandula',
        category: 'Outdoor',
        difficulty: 'Easy',
        light: 'Full Sun',
        water: 'Low',
        tags: ['Fragrant', 'Medicinal', 'Drought Tolerant'],
        description: 'Beautiful purple flowers with calming fragrance. Perfect for gardens.',
        icon: 'local_florist_rounded',
      },
      {
        name: 'Tomato Plant',
        scientificName: 'Solanum lycopersicum',
        category: 'Outdoor',
        difficulty: 'Moderate',
        light: 'Full Sun',
        water: 'Medium',
        tags: ['Edible', 'Fruiting', 'Garden'],
        description: 'Popular vegetable plant. Requires consistent watering and full sun.',
        icon: 'park_rounded',
      },
      // Low Maintenance category (2 plants)
      {
        name: 'Snake Plant',
        scientificName: 'Sansevieria trifasciata',
        category: 'Low Maintenance',
        difficulty: 'Easy',
        light: 'Low to Bright',
        water: 'Low',
        tags: ['Pet Safe', 'Air Purifying', 'Drought Tolerant'],
        description: 'Extremely low maintenance, perfect for beginners. Thrives on neglect.',
        icon: 'grass_rounded',
      },
      {
        name: 'ZZ Plant',
        scientificName: 'Zamioculcas zamiifolia',
        category: 'Low Maintenance',
        difficulty: 'Easy',
        light: 'Low to Bright',
        water: 'Very Low',
        tags: ['Drought Tolerant', 'Pet Safe', 'Indestructible'],
        description: 'Nearly indestructible. Perfect for forgetful plant parents.',
        icon: 'local_florist_rounded',
      },
      // Pet Safe category (2 plants)
      {
        name: 'Spider Plant',
        scientificName: 'Chlorophytum comosum',
        category: 'Pet Safe',
        difficulty: 'Easy',
        light: 'Bright Indirect',
        water: 'Medium',
        tags: ['Air Purifying', 'Propagates Easily', 'Non-Toxic'],
        description: 'Produces baby plants. Great for beginners and pets. Completely safe.',
        icon: 'water_drop_rounded',
      },
      {
        name: 'Boston Fern',
        scientificName: 'Nephrolepis exaltata',
        category: 'Pet Safe',
        difficulty: 'Easy',
        light: 'Bright Indirect',
        water: 'Medium',
        tags: ['Air Purifying', 'Humidity Loving', 'Non-Toxic'],
        description: 'Lush green fronds. Safe for pets and great for air quality.',
        icon: 'nature_rounded',
      },
      // Flowering category (2 plants)
      {
        name: 'Peace Lily',
        scientificName: 'Spathiphyllum',
        category: 'Flowering',
        difficulty: 'Easy',
        light: 'Low to Medium',
        water: 'Medium',
        tags: ['Air Purifying', 'Low Light', 'White Blooms'],
        description: 'Elegant white blooms. Tolerates low light conditions.',
        icon: 'local_florist_rounded',
      },
      {
        name: 'African Violet',
        scientificName: 'Saintpaulia',
        category: 'Flowering',
        difficulty: 'Moderate',
        light: 'Bright Indirect',
        water: 'Medium',
        tags: ['Colorful', 'Compact', 'Indoor Blooms'],
        description: 'Beautiful purple, pink, or white flowers. Blooms year-round indoors.',
        icon: 'diamond_rounded',
      },
    ];

    await ExplorePlant.insertMany(defaultPlants);
  }

  /**
   * Seed initial problems data
   */
  async seedProblems(): Promise<void> {
    const count = await Problem.countDocuments();
    if (count > 0) {
      return; // Already seeded
    }

    const defaultProblems = [
      {
        name: 'Aphids',
        category: 'Pests',
        description: 'Small green or black insects clustering on new growth',
        severity: 'Moderate',
        treatmentDifficulty: 'Easy',
        icon: 'bug_report_rounded',
        color: '#EF4444',
        commonCauses: ['Weak plants', 'Over-fertilization', 'Dry conditions'],
        solutions: [
          'Spray with water to dislodge',
          'Use insecticidal soap',
          'Introduce beneficial insects like ladybugs',
          'Apply neem oil treatment',
        ],
        prevention: 'Keep plants healthy and well-watered. Regularly inspect new growth.',
        affectedPlants: ['Most plants', 'Especially roses', 'Vegetables'],
      },
      {
        name: 'Spider Mites',
        category: 'Pests',
        description: 'Tiny red or brown mites causing webbing and yellowing',
        severity: 'Severe',
        treatmentDifficulty: 'Moderate',
        icon: 'bug_report_rounded',
        color: '#DC2626',
        commonCauses: ['Dry air', 'Overcrowding', 'Poor ventilation'],
        solutions: [
          'Increase humidity around plants',
          'Wipe leaves with damp cloth',
          'Use miticide or insecticidal soap',
          'Isolate affected plants immediately',
        ],
        prevention: 'Maintain 40-50% humidity. Space plants properly for air circulation.',
        affectedPlants: ['Houseplants', 'Indoor plants', 'Dry environment lovers'],
      },
      {
        name: 'Yellowing Leaves',
        category: 'Environmental',
        description: 'Leaves turning yellow, often starting from bottom',
        severity: 'Mild',
        treatmentDifficulty: 'Easy',
        icon: 'warning_rounded',
        color: '#F59E0B',
        commonCauses: ['Overwatering', 'Underwatering', 'Nutrient deficiency', 'Natural aging'],
        solutions: [
          'Check soil moisture - adjust watering schedule',
          'Test for nutrient deficiencies',
          'Ensure proper drainage',
          'Trim yellow leaves if necessary',
        ],
        prevention: 'Water only when top inch of soil is dry. Fertilize regularly during growing season.',
        affectedPlants: ['All plants', 'Most common in overwatered plants'],
      },
      {
        name: 'Brown Leaf Tips',
        category: 'Environmental',
        description: 'Leaf tips turning brown and crispy',
        severity: 'Mild',
        treatmentDifficulty: 'Easy',
        icon: 'circle_rounded',
        color: '#92400E',
        commonCauses: ['Low humidity', 'Over-fertilization', 'Salt buildup', 'Underwatering'],
        solutions: [
          'Increase humidity with humidifier or pebble tray',
          'Flush soil with water to remove salts',
          'Reduce fertilizer frequency',
          'Trim brown tips with clean scissors',
        ],
        prevention: 'Use filtered water. Maintain 40-60% humidity. Don\'t over-fertilize.',
        affectedPlants: ['Spider plants', 'Dracaena', 'Palms', 'Ferns'],
      },
      {
        name: 'Root Rot',
        category: 'Watering',
        description: 'Overwatering causing roots to decay and turn mushy',
        severity: 'Severe',
        treatmentDifficulty: 'Moderate',
        icon: 'water_damage_rounded',
        color: '#DC2626',
        commonCauses: ['Overwatering', 'Poor drainage', 'Heavy soil', 'Oversized pots'],
        solutions: [
          'Remove plant and trim affected roots',
          'Repot in fresh, well-draining soil',
          'Reduce watering frequency significantly',
          'Ensure pot has drainage holes',
        ],
        prevention: 'Water only when soil is dry. Use pots with drainage. Choose appropriate soil mix.',
        affectedPlants: ['Succulents', 'Overwatered plants', 'Plants in heavy soil'],
      },
      {
        name: 'Wilting',
        category: 'Watering',
        description: 'Plants drooping or losing turgor pressure',
        severity: 'Moderate',
        treatmentDifficulty: 'Easy',
        icon: 'arrow_downward_rounded',
        color: '#3B82F6',
        commonCauses: ['Underwatering', 'Overwatering', 'Root issues', 'Heat stress'],
        solutions: [
          'Check soil moisture immediately',
          'Water if dry, let dry if overwatered',
          'Move to cooler location if heat stressed',
          'Check roots for damage',
        ],
        prevention: 'Establish consistent watering routine. Protect from extreme temperatures.',
        affectedPlants: ['All plants', 'Especially those with high water needs'],
      },
      {
        name: 'Powdery Mildew',
        category: 'Diseases',
        description: 'White powdery fungus on leaves and stems',
        severity: 'Moderate',
        treatmentDifficulty: 'Moderate',
        icon: 'science_rounded',
        color: '#9333EA',
        commonCauses: ['High humidity', 'Poor air circulation', 'Cool temperatures', 'Crowded plants'],
        solutions: [
          'Improve air circulation around plants',
          'Remove affected leaves',
          'Apply fungicide or baking soda solution',
          'Reduce humidity if possible',
        ],
        prevention: 'Space plants properly. Avoid overhead watering. Ensure good ventilation.',
        affectedPlants: ['Squash', 'Cucumbers', 'Houseplants', 'Outdoor ornamentals'],
      },
      {
        name: 'Leaf Spot',
        category: 'Diseases',
        description: 'Brown or black spots with yellow halos on leaves',
        severity: 'Moderate',
        treatmentDifficulty: 'Easy',
        icon: 'brightness_1_rounded',
        color: '#8B4513',
        commonCauses: ['Fungal infection', 'Bacterial infection', 'Water on leaves', 'Poor hygiene'],
        solutions: [
          'Remove affected leaves',
          'Avoid overhead watering',
          'Improve air circulation',
          'Apply fungicide if severe',
        ],
        prevention: 'Water at base of plant. Keep leaves dry. Clean pruning tools between uses.',
        affectedPlants: ['Roses', 'Vegetables', 'Ornamental plants'],
      },
      {
        name: 'Nutrient Deficiency',
        category: 'Nutrition',
        description: 'Lack of essential nutrients causing various symptoms',
        severity: 'Moderate',
        treatmentDifficulty: 'Easy',
        icon: 'bloodtype_rounded',
        color: '#14B8A6',
        commonCauses: ['Poor soil', 'Lack of fertilization', 'pH imbalance', 'Root damage'],
        solutions: [
          'Test soil pH and nutrients',
          'Apply balanced fertilizer',
          'Use specific nutrient supplements',
          'Repot with fresh nutrient-rich soil',
        ],
        prevention: 'Fertilize regularly during growing season. Use quality potting mix. Monitor pH.',
        affectedPlants: ['All plants', 'Especially container plants'],
      },
    ];

    await Problem.insertMany(defaultProblems);
  }
}
