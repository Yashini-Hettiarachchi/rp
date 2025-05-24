import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ENVConfig {
  // Server Details
  // For local development use: 'http://localhost:8000'
  // For production use your AWS Elastic Beanstalk URL: 'https://your-eb-environment.elasticbeanstalk.com'
  // For Hostinger deployment: 'https://yourdomain.com/api'

  // IMPORTANT: Update this URL with your actual AWS Elastic Beanstalk URL before deployment
  static const bool useMockData =
      true; // Set to false when backend is available
  static const String serverUrl =
      'https://9535-103-21-164-181.ngrok-free.app'; // Development
  // static const String serverUrl = 'https://your-eb-environment.elasticbeanstalk.com';  // Production
  static const String predictionUrl =
      'https://yasiruperera.pythonanywhere.com/predict';

  // API Route
  static const String loginRoute = '/api/login';

  // Function to check if a level should be unlocked
  static Future<bool> isLevelUnlocked(
      int level, double currentGrade, double timeTaken) async {
    // Level 1 is always unlocked
    if (level == 1) return true;

    try {
      final response = await http.get(
        Uri.parse('$predictionUrl?grade=$currentGrade&time_taken=$timeTaken'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final adjustment = data['adjustment'] as double;

        // If adjustment is positive, unlock next level
        // If adjustment is negative, lock current level
        return adjustment > 0;
      }
      return false;
    } catch (e) {
      print('Error checking level access: $e');
      return false;
    }
  }

  // Function to get level access status
  static Future<Map<int, bool>> getLevelAccessStatus(
      double currentGrade, double timeTaken) async {
    Map<int, bool> levelAccess = {};

    // Level 1 is always unlocked
    levelAccess[1] = true;

    // Check access for other levels
    for (int i = 2; i <= levels.length; i++) {
      levelAccess[i] = await isLevelUnlocked(i, currentGrade, timeTaken);
    }

    return levelAccess;
  }

  static final List<Map<String, dynamic>> levels = [
    {
      "title": "Level 1: Word Matching 🔤",
      "description": "Match words with their meanings",
      "difficulty": 0,
      "type": "basic",
      "color": Colors.blue,
      "background": "assets/backgrounds/level1.jpg",
      "questions": [
        {
          "question": "What do you use to hold things?",
          "options": ["Hand", "Book", "Tree", "Car"],
          "answer": "Hand"
        },
        {
          "question": "What color is the sky on a sunny day?",
          "options": ["Blue", "Red", "Green", "Yellow"],
          "answer": "Blue"
        },
        {
          "question": "What fruit is red and sweet?",
          "options": ["Apple", "Car", "House", "Dog"],
          "answer": "Apple"
        },
        {
          "question": "What do you sit on in class?",
          "options": ["Chair", "Table", "Bed", "Desk"],
          "answer": "Chair"
        },
        {
          "question": "What do you use to write in your notebook?",
          "options": ["Pencil", "Eraser", "Ruler", "Scissors"],
          "answer": "Pencil"
        },
        {
          "question": "What pet says 'woof woof'?",
          "options": ["Dog", "Cat", "Bird", "Fish"],
          "answer": "Dog"
        },
        {
          "question": "Where do you live with your family?",
          "options": ["House", "School", "Park", "Store"],
          "answer": "House"
        },
        {
          "question": "What do you ride in to go places?",
          "options": ["Car", "Bike", "Boat", "Plane"],
          "answer": "Car"
        },
        {
          "question": "Where do you go to learn new things?",
          "options": ["School", "Hospital", "Park", "Beach"],
          "answer": "School"
        },
        {
          "question": "Who helps you learn in class?",
          "options": ["Teacher", "Doctor", "Farmer", "Driver"],
          "answer": "Teacher"
        }
      ]
    },
    {
      "title": "Level 1: Filling Blanks ✏️",
      "description": "Complete the sentences with correct words",
      "difficulty": 0,
      "type": "basic",
      "color": Colors.green,
      "background": "assets/backgrounds/level2.jpg",
      "questions": [
        {
          "question": "The big yellow ___ gives us light during the day.",
          "options": ["sun", "moon", "star", "cloud"],
          "answer": "sun"
        },
        {
          "question": "I use my favorite ___ to do my homework.",
          "options": ["pencil", "eraser", "ruler", "scissors"],
          "answer": "pencil"
        },
        {
          "question": "My friendly ___ likes to play fetch with a ball.",
          "options": ["dog", "cat", "bird", "fish"],
          "answer": "dog"
        },
        {
          "question": "I eat a yummy ___ for my snack.",
          "options": ["apple", "orange", "banana", "grape"],
          "answer": "apple"
        },
        {
          "question": "The pretty ___ is blue with fluffy white clouds.",
          "options": ["sky", "ground", "water", "grass"],
          "answer": "sky"
        },
        {
          "question": "I put on my colorful ___ when it rains.",
          "options": ["raincoat", "hat", "gloves", "scarf"],
          "answer": "raincoat"
        },
        {
          "question": "The round ___ helps me know when to go to school.",
          "options": ["clock", "book", "pen", "desk"],
          "answer": "clock"
        },
        {
          "question": "I use my soft ___ to clean my teeth.",
          "options": ["toothbrush", "comb", "soap", "towel"],
          "answer": "toothbrush"
        },
        {
          "question": "The bright ___ helps me read at night.",
          "options": ["lamp", "chair", "table", "bed"],
          "answer": "lamp"
        },
        {
          "question": "I put all my school things in my favorite ___.",
          "options": ["backpack", "box", "bag", "basket"],
          "answer": "backpack"
        }
      ]
    },
    {
      "title": "Level 1: Visual Identification 👁️",
      "description": "Identify objects from pictures 🖼️",
      "difficulty": 0,
      "type": "basic",
      "color": Colors.orange,
      "background": "assets/backgrounds/level3.jpg",
      "questions": [
        {
          "question": "What is this?",
          "imagePath": "assets/images/kitchen/cup.png",
          "options": ["Cup", "Foot", "Ear", "Nose"],
          "answer": "Cup"
        },
        {
          "question": "🎨 What color is this cup?",
          "imagePath": "assets/images/kitchen/cup.png",
          "options": ["Red", "Blue", "Green", "Yellow"],
          "answer": "Red"
        },
        {
          "question": "What is this?",
          "imagePath": "assets/images/kitchen/spoon.png",
          "options": ["Spoon", "Orange", "Banana", "Grape"],
          "answer": "Spoon"
        },
        {
          "question": "What is this object?",
          "imagePath": "assets/images/icons/gift.png",
          "options": ["Gift", "Table", "Bed", "Desk"],
          "answer": "Gift"
        },
        {
          "question": "What is this object?",
          "imagePath": "assets/images/desk/pen1.png",
          "options": ["Pen", "Eraser", "Ruler", "Scissors"],
          "answer": "Pen"
        },
        {
          "question": "What is this?",
          "imagePath": "assets/images/animals/dog.png",
          "options": ["Dog", "Cat", "Bird", "Fish"],
          "answer": "Dog"
        },
        {
          "question": "What is this?",
          "imagePath": "assets/desk/eraser1.png",
          "options": ["Eraser", "Pen", "Pencil", "Car"],
          "answer": "Eraser"
        },
        {
          "question": "What place is this?",
          "imagePath": "assets/desk/book2.png",
          "options": ["Book", "Pen", "Pencil", "Car"],
          "answer": "Book"
        },
        {
          "question": "What is this?",
          "imagePath": "assets/desk/book1.png",
          "options": ["Book", "Pen", "Pencil", "Car"],
          "answer": "Book"
        }
      ]
    },
    {
      "title": "Level 3: Transportation 🚗",
      "cardPack": "Themes: Vehicles & Travel",
      "description": "Learn about different modes of transportation",
      "difficulty": 1,
      "type": "normal",
      "color": const Color(0xFF2196F3),
      "questions": [
        {
          "question": "What big yellow vehicle takes you to school?",
          "options": ["School Bus", "Airplane", "Ship", "Train"],
          "answer": "School Bus"
        },
        {
          "question":
              "What do you ride when you want to have fun and exercise?",
          "options": ["Bicycle", "Car", "Bus", "Train"],
          "answer": "Bicycle"
        },
        {
          "question": "What long vehicle goes 'choo choo' on tracks?",
          "options": ["Train", "Bus", "Car", "Bicycle"],
          "answer": "Train"
        },
        {
          "question": "What big boat can carry cars across water?",
          "options": ["Ferry", "Airplane", "Car", "Train"],
          "answer": "Ferry"
        },
        {
          "question": "What do you take to go shopping with your family?",
          "options": ["Bus", "Car", "Train", "Bicycle"],
          "answer": "Bus"
        },
        {
          "question": "What flying vehicle can help people in trouble?",
          "options": ["Helicopter", "Airplane", "Rocket", "Balloon"],
          "answer": "Helicopter"
        },
        {
          "question": "What small boat do you use to go fishing with dad?",
          "options": ["Boat", "Ship", "Submarine", "Raft"],
          "answer": "Boat"
        },
        {
          "question": "What special vehicle takes people to the moon?",
          "options": ["Rocket", "Airplane", "Helicopter", "Balloon"],
          "answer": "Rocket"
        },
        {
          "question": "What big flying vehicle takes you on vacation?",
          "options": ["Airplane", "Helicopter", "Rocket", "Balloon"],
          "answer": "Airplane"
        },
        {
          "question": "What do you ride to the park with your friends?",
          "options": ["Bicycle", "Car", "Bus", "Train"],
          "answer": "Bicycle"
        }
      ]
    },
    {
      "title": "Level 4: Nature & Environment 🌿",
      "cardPack": "Themes: Weather & Seasons",
      "description": "Learn about natural phenomena and seasons",
      "difficulty": 1,
      "type": "normal",
      "color": const Color(0xFFFF5722),
      "questions": [
        {
          "question": "What happens to water when you put it in the freezer?",
          "options": [
            "It freezes",
            "It evaporates",
            "It disappears",
            "It changes color"
          ],
          "answer": "It freezes"
        },
        {
          "question": "What do you hold over your head when it's raining?",
          "options": ["Umbrella", "Sunglasses", "Hat", "Gloves"],
          "answer": "Umbrella"
        },
        {
          "question": "What fun thing can you make when it snows?",
          "options": ["Snowman", "Sandcastle", "Mud pie", "Leaf pile"],
          "answer": "Snowman"
        },
        {
          "question": "What's the safest thing to do when there's a big storm?",
          "options": [
            "Stay inside",
            "Go outside",
            "Play in the rain",
            "Climb trees"
          ],
          "answer": "Stay inside"
        },
        {
          "question": "What do you wear to go swimming in the pool?",
          "options": ["Swimsuit", "Winter coat", "Rain boots", "Sweater"],
          "answer": "Swimsuit"
        },
        {
          "question": "What hot, red stuff comes out of a volcano?",
          "options": ["Lava", "Water", "Air", "Sand"],
          "answer": "Lava"
        },
        {
          "question": "What makes the leaves dance on the trees?",
          "options": ["Wind", "Rain", "Snow", "Sun"],
          "answer": "Wind"
        },
        {
          "question":
              "What makes it hard to see when you walk to school in the morning?",
          "options": ["Fog", "Rain", "Snow", "Wind"],
          "answer": "Fog"
        },
        {
          "question": "What makes a big 'BOOM' sound during a storm?",
          "options": ["Thunder", "Wind", "Rain", "Snow"],
          "answer": "Thunder"
        },
        {
          "question": "What helps your kite fly high in the sky?",
          "options": ["Wind", "Rain", "Snow", "Sun"],
          "answer": "Wind"
        }
      ]
    },
    {
      "title": "Level 5: Calculation Improvement 🧮",
      "cardPack": "Themes: Numbers & Math",
      "description": "Combine word recognition with basic arithmetic",
      "difficulty": 2,
      "type": "basic",
      "color": const Color(0xFF673AB7),
      "questions": [
        {
          "question": "🔢 What is 2 + 2?",
          "options": ["4", "5", "3", "6"],
          "answer": "4"
        },
        {
          "question": "🖐️ How many fingers are on one hand?",
          "options": ["Five", "Four", "Six", "Three"],
          "answer": "Five"
        },
        {
          "question": "🎲 What number comes after 9?",
          "options": ["10", "8", "11", "7"],
          "answer": "10"
        },
        {
          "question": "🔢 What is 5 - 3?",
          "options": ["2", "3", "1", "4"],
          "answer": "2"
        },
        {
          "question": "🧮 What is 3 x 3?",
          "options": ["9", "6", "12", "15"],
          "answer": "9"
        },
        {
          "question": "📏 How many sides does a triangle have?",
          "options": ["3", "4", "5", "6"],
          "answer": "3"
        },
        {
          "question": "🔢 What is 10 divided by 2?",
          "options": ["5", "4", "6", "3"],
          "answer": "5"
        },
        {
          "question": "🎲 What number comes before 1?",
          "options": ["0", "2", "3", "4"],
          "answer": "0"
        },
        {
          "question": "🔢 What is 7 + 5?",
          "options": ["12", "10", "11", "13"],
          "answer": "12"
        },
        {
          "question": "📐 How many sides does a square have?",
          "options": ["4", "3", "5", "6"],
          "answer": "4"
        }
      ]
    },
    {
      "title": "Level 6: Time Identification ⏰",
      "cardPack": "Themes: Time & Clocks",
      "description": "Develop time-reading skills",
      "difficulty": 3,
      "type": "normal",
      "color": const Color(0xFF3F51B5),
      "questions": [
        {
          "question": "⏰ What time is it when the clock shows 12:00?",
          "options": ["Noon", "Midnight", "Morning", "Evening"],
          "answer": "Noon"
        },
        {
          "question": "🕒 How many hours are in a day?",
          "options": ["24", "12", "36", "48"],
          "answer": "24"
        },
        {
          "question": "🕑 What time is it when the clock shows 2:00?",
          "options": [
            "Two o'clock",
            "Three o'clock",
            "One o'clock",
            "Four o'clock"
          ],
          "answer": "Two o'clock"
        },
        {
          "question": "🕓 How many minutes are in an hour?",
          "options": ["60", "30", "45", "90"],
          "answer": "60"
        },
        {
          "question": "⏳ How many seconds are in a minute?",
          "options": ["60", "100", "30", "45"],
          "answer": "60"
        },
        {
          "question": "🕕 What time is it when the clock shows 6:00?",
          "options": [
            "Six o'clock",
            "Seven o'clock",
            "Five o'clock",
            "Eight o'clock"
          ],
          "answer": "Six o'clock"
        },
        {
          "question": "🕛 What time is it when the clock shows 12:00 at night?",
          "options": ["Midnight", "Noon", "Morning", "Evening"],
          "answer": "Midnight"
        },
        {
          "question": "🕗 What time is it when the clock shows 8:00?",
          "options": [
            "Eight o'clock",
            "Nine o'clock",
            "Seven o'clock",
            "Ten o'clock"
          ],
          "answer": "Eight o'clock"
        },
        {
          "question": "⏰ How many hours are in half a day?",
          "options": ["12", "6", "24", "18"],
          "answer": "12"
        },
        {
          "question": "🕐 What time is it when the clock shows 1:00?",
          "options": [
            "One o'clock",
            "Two o'clock",
            "Twelve o'clock",
            "Three o'clock"
          ],
          "answer": "One o'clock"
        }
      ]
    },
    {
      "title": "Level 7: Advanced Vocabulary 📚",
      "cardPack": "Themes: Professions & Nature",
      "description": "Learn advanced vocabulary through professions and nature",
      "difficulty": 4,
      "type": "normal",
      "color": const Color(0xFF9C27B0),
      "questions": [
        {
          "question": "👩‍🏫 Who teaches students in a school?",
          "options": ["Teacher", "Doctor", "Nurse", "Chef"],
          "answer": "Teacher"
        },
        {
          "question": "🔧 What do you call a person who fixes cars?",
          "options": ["Mechanic", "Chef", "Teacher", "Doctor"],
          "answer": "Mechanic"
        },
        {
          "question": "🏔️ What is a tall mountain covered with snow called?",
          "options": ["Peak", "Valley", "Hill", "Plain"],
          "answer": "Peak"
        },
        {
          "question": "👨‍🍳 What do you call a person who cooks food?",
          "options": ["Chef", "Mechanic", "Teacher", "Doctor"],
          "answer": "Chef"
        },
        {
          "question": "🌊 What flows in a valley and carries water?",
          "options": ["River", "Mountain", "Hill", "Plain"],
          "answer": "River"
        },
        {
          "question":
              "🌳 What do you call a large plant with a trunk and branches?",
          "options": ["Tree", "Bush", "Flower", "Grass"],
          "answer": "Tree"
        },
        {
          "question": "🦁 What is the king of the jungle?",
          "options": ["Lion", "Tiger", "Bear", "Wolf"],
          "answer": "Lion"
        },
        {
          "question": "🌋 What do you call a mountain that erupts with lava?",
          "options": ["Volcano", "Hill", "Mountain", "Valley"],
          "answer": "Volcano"
        },
        {
          "question": "👨‍🚀 Who travels to space?",
          "options": ["Astronaut", "Pilot", "Driver", "Sailor"],
          "answer": "Astronaut"
        },
        {
          "question": "🌌 What do you call the collection of stars in the sky?",
          "options": ["Galaxy", "Planet", "Star", "Moon"],
          "answer": "Galaxy"
        }
      ]
    }
  ];
}
