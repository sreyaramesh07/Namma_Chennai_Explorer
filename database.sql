CREATE DATABASE IF NOT EXISTS namma_chennai;
USE namma_chennai;

CREATE TABLE IF NOT EXISTS places (
    place_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    location VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    entry_fee DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    opening_time TIME NOT NULL,
    closing_time TIME NOT NULL,
    best_time_to_visit VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS food (
    food_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    `type` VARCHAR(50) NOT NULL,
    location VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    average_price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE IF NOT EXISTS trips (
    trip_id INT AUTO_INCREMENT PRIMARY KEY,
    duration VARCHAR(50) NOT NULL,
    budget DECIMAL(10, 2) NOT NULL,
    starting_location VARCHAR(100) NOT NULL,
    interests VARCHAR(255) NOT NULL
);

INSERT INTO places (name, category, location, description, entry_fee, opening_time, closing_time, best_time_to_visit) VALUES
('Marina Beach', 'Beach', 'Marina', 'Chennai’s iconic urban beach, ideal for walks and sea views.', 0.00, '00:00:00', '23:59:59', 'Early morning or evening'),
('Besant Nagar Beach', 'Beach', 'Besant Nagar', 'Popular beach near Elliot’s Beach with cafes and a relaxed atmosphere.', 0.00, '00:00:00', '23:59:59', 'Evening'),
('Fort St. George', 'Historical Place', 'George Town', 'A 17th-century British fort housing the Fort Museum.', 25.00, '09:00:00', '17:00:00', 'November to February'),
('Government Museum Chennai', 'Museum', 'Egmore', 'One of India’s oldest museums with archaeology, art and natural history collections.', 15.00, '09:30:00', '17:00:00', 'Morning'),
('Kapaleeshwarar Temple', 'Temple', 'Mylapore', 'A historic Dravidian-style Shiva temple in the heart of Mylapore.', 0.00, '05:00:00', '21:00:00', 'Early morning or evening'),
('Parthasarathy Temple', 'Temple', 'Triplicane', 'Ancient Vishnu temple known for its detailed gopuram and heritage.', 0.00, '06:00:00', '20:30:00', 'Morning'),
('Guindy National Park', 'Nature', 'Guindy', 'A protected urban forest with deer, birds and walking areas.', 20.00, '09:00:00', '17:30:00', 'November to February'),
('Semmozhi Poonga', 'Park', 'Teynampet', 'Well-maintained botanical garden with themed plants and peaceful paths.', 20.00, '10:00:00', '19:30:00', 'Evening'),
('Valluvar Kottam', 'Historical Place', 'Nungambakkam', 'Memorial dedicated to Tamil poet Thiruvalluvar with a grand auditorium.', 10.00, '08:30:00', '17:30:00', 'Morning'),
('DakshinaChitra', 'Museum', 'Muttukadu', 'Living-history museum showcasing South Indian homes, crafts and culture.', 175.00, '10:00:00', '18:00:00', 'November to February'),
('Arignar Anna Zoological Park', 'Nature', 'Vandalur', 'Large zoological park with diverse animals and safari experiences.', 200.00, '09:00:00', '17:00:00', 'Morning in winter'),
('Anna Nagar Tower Park', 'Park', 'Anna Nagar', 'Public park with lawns, walking paths and a landmark tower.', 0.00, '06:00:00', '20:00:00', 'Morning or evening'),
('Pondy Bazaar', 'Shopping', 'T. Nagar', 'Busy street-shopping area for clothes, accessories and local snacks.', 0.00, '10:00:00', '22:00:00', 'Weekday evening'),
('Phoenix Marketcity', 'Shopping', 'Velachery', 'Modern mall with shops, restaurants and cinema.', 0.00, '10:00:00', '22:00:00', 'Afternoon or evening'),
('VGP Universal Kingdom', 'Entertainment', 'Injambakkam', 'Family amusement park with rides and shows near ECR.', 699.00, '10:00:00', '19:00:00', 'Weekday morning'),
('Theosophical Society Gardens', 'Nature', 'Adyar', 'Quiet green campus known for its old banyan tree and birdlife.', 0.00, '08:30:00', '16:00:00', 'November to February');

INSERT INTO food (name, `type`, location, description, average_price) VALUES
('Idli and Vada', 'South Indian Breakfast', 'Mylapore', 'Steamed idlis and crisp vadas served with sambar and chutneys.', 80.00),
('Filter Coffee', 'Beverage', 'Mylapore', 'Traditional strong coffee served in a steel tumbler and davara.', 40.00),
('Kothu Parotta', 'Street Food', 'T. Nagar', 'Shredded parotta cooked on a hot griddle with spices and gravy.', 120.00),
('Chennai Chicken 65', 'Chettinad', 'Velachery', 'Spicy fried chicken dish with curry leaves and South Indian seasoning.', 220.00),
('Sundal at Marina', 'Beach Snack', 'Marina', 'Boiled chickpeas mixed with coconut, mango and mild spices.', 40.00),
('Murukku Sandwich', 'Street Food', 'Sowcarpet', 'Crunchy local snack experience in Chennai’s busy market streets.', 60.00),
('Vegetarian Meals', 'South Indian Meals', 'Triplicane', 'Rice with sambar, rasam, vegetables, curd and appalam.', 150.00),
('Athirasam', 'Sweet', 'Mylapore', 'Traditional jaggery and rice flour sweet.', 50.00),
('Seafood Fry', 'Seafood', 'Besant Nagar', 'Fresh fish fry served near the beach.', 280.00),
('Jigarthanda', 'Dessert Drink', 'Anna Nagar', 'Cold milk-based dessert drink with almond gum and ice cream.', 120.00);
