CREATE DATABASE IF NOT EXISTS namma_chennai;
USE namma_chennai;

-- This schema upgrades the V1 tables in place and is safe to run again on MySQL 8.0.29+.
CREATE TABLE IF NOT EXISTS places (
    place_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    location VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    entry_fee DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    estimated_cost DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    visit_duration VARCHAR(50) NOT NULL DEFAULT '1–2 hours',
    opening_time TIME NOT NULL,
    closing_time TIME NOT NULL,
    best_time_to_visit VARCHAR(100) NOT NULL,
    UNIQUE KEY uq_places_name (name)
);

-- Required only when upgrading a V1 database that already has a places table.
ALTER TABLE places ADD COLUMN IF NOT EXISTS estimated_cost DECIMAL(10,2) NOT NULL DEFAULT 0.00 AFTER entry_fee;
ALTER TABLE places ADD COLUMN IF NOT EXISTS visit_duration VARCHAR(50) NOT NULL DEFAULT '1–2 hours' AFTER estimated_cost;
ALTER TABLE places ADD UNIQUE INDEX IF NOT EXISTS uq_places_name (name);
UPDATE places SET estimated_cost = entry_fee WHERE estimated_cost = 0 AND entry_fee > 0;

CREATE TABLE IF NOT EXISTS trips (
    trip_id INT AUTO_INCREMENT PRIMARY KEY,
    duration TINYINT NOT NULL,
    budget DECIMAL(10,2) NOT NULL,
    starting_location VARCHAR(100) NOT NULL,
    interests VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO places (name, category, location, description, entry_fee, estimated_cost, visit_duration, opening_time, closing_time, best_time_to_visit) VALUES
('Marina Beach', 'Beach', 'Marina', 'Chennai’s iconic urban beach, ideal for a sunrise walk, sea views and street snacks.', 0, 100, '2–3 hours', '00:00:00', '23:59:59', 'Early morning or evening'),
('Besant Nagar Beach', 'Beach', 'Besant Nagar', 'A relaxed seaside favourite near cafés, street food and Elliot’s Beach.', 0, 150, '2–3 hours', '00:00:00', '23:59:59', 'Evening'),
('Fort St. George', 'Historical Place', 'George Town', 'A 17th-century landmark with the Fort Museum and a view into Chennai’s colonial past.', 25, 100, '1–2 hours', '09:00:00', '17:00:00', 'Morning'),
('Government Museum Chennai', 'Museum', 'Egmore', 'One of India’s oldest museums, with archaeology, art and natural-history collections.', 15, 100, '2–3 hours', '09:30:00', '17:00:00', 'Morning'),
('Kapaleeshwarar Temple', 'Temple', 'Mylapore', 'A historic Dravidian-style Shiva temple in the heart of Mylapore.', 0, 50, '1 hour', '05:00:00', '21:00:00', 'Early morning or evening'),
('Parthasarathy Temple', 'Temple', 'Triplicane', 'Ancient Vishnu temple known for its detailed gopuram and heritage.', 0, 50, '1 hour', '06:00:00', '20:30:00', 'Morning'),
('Guindy National Park', 'Nature', 'Guindy', 'A protected urban forest with deer, birds and walking areas.', 20, 120, '2–3 hours', '09:00:00', '17:30:00', 'November to February'),
('Semmozhi Poonga', 'Park', 'Teynampet', 'A botanical garden with themed plants and peaceful paths.', 20, 100, '1–2 hours', '10:00:00', '19:30:00', 'Evening'),
('Valluvar Kottam', 'Historical Place', 'Nungambakkam', 'A memorial to Tamil poet Thiruvalluvar with a grand auditorium.', 10, 60, '1 hour', '08:30:00', '17:30:00', 'Morning'),
('DakshinaChitra', 'Museum', 'Muttukadu', 'A living-history museum of South Indian homes, crafts and culture.', 175, 300, '3–4 hours', '10:00:00', '18:00:00', 'Morning'),
('Arignar Anna Zoological Park', 'Nature', 'Vandalur', 'A large zoological park with animals, safari experiences and long walking trails.', 200, 350, '4–5 hours', '09:00:00', '17:00:00', 'Morning in winter'),
('Pondy Bazaar', 'Shopping', 'T. Nagar', 'Busy street shopping for clothes, accessories and local snacks.', 0, 400, '2–3 hours', '10:00:00', '22:00:00', 'Weekday evening'),
('Phoenix Marketcity', 'Shopping', 'Velachery', 'A modern mall with shops, restaurants and cinema.', 0, 650, '3–4 hours', '10:00:00', '22:00:00', 'Afternoon or evening'),
('VGP Universal Kingdom', 'Entertainment', 'Injambakkam', 'A family amusement park with rides and shows near ECR.', 699, 850, '5–6 hours', '10:00:00', '19:00:00', 'Weekday morning'),
('Theosophical Society Gardens', 'Nature', 'Adyar', 'A quiet green campus known for its old banyan tree and birdlife.', 0, 50, '1–2 hours', '08:30:00', '16:00:00', 'November to February'),
('Mylapore Tiffin Trail', 'Food', 'Mylapore', 'A classic South Indian breakfast stop for idli, vada and filter coffee.', 0, 150, '1 hour', '07:00:00', '11:30:00', 'Breakfast'),
('Sowcarpet Street Food Walk', 'Food', 'Sowcarpet', 'A lively local-food stop for chaat, snacks and sweets.', 0, 250, '1–2 hours', '11:00:00', '22:00:00', 'Late afternoon'),
('Amma Unavagam', 'Food', 'Multiple locations', 'A budget-friendly Tamil Nadu canteen meal experience.', 0, 60, '45 minutes', '07:00:00', '21:00:00', 'Lunch')
ON DUPLICATE KEY UPDATE category=VALUES(category), location=VALUES(location), description=VALUES(description), entry_fee=VALUES(entry_fee), estimated_cost=VALUES(estimated_cost), visit_duration=VALUES(visit_duration), opening_time=VALUES(opening_time), closing_time=VALUES(closing_time), best_time_to_visit=VALUES(best_time_to_visit);
