-- Enable UUID generation extension
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. Users Table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    age INT,
    gender VARCHAR(20),
    weight_kg NUMERIC(5, 2),
    height_cm NUMERIC(5, 2),
    fitness_goal VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Workouts / Routines Table
CREATE TABLE IF NOT EXISTS workouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    split_type VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Exercises Table (Reference Library)
CREATE TABLE IF NOT EXISTS exercises (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    target_muscle VARCHAR(50) NOT NULL,
    equipment_required VARCHAR(50),
    instructions TEXT
);

-- 4. Workout Logs Table (Completed Sessions)
CREATE TABLE IF NOT EXISTS workout_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    workout_id UUID REFERENCES workouts(id) ON DELETE SET NULL,
    exercise_id UUID REFERENCES exercises(id) ON DELETE RESTRICT,
    sets_completed INT NOT NULL,
    reps_completed INT NOT NULL,
    weight_used_kg NUMERIC(5, 2),
    logged_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. Food Items Table (Reference Library)
CREATE TABLE IF NOT EXISTS food_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    serving_size_grams NUMERIC(6, 2) NOT NULL DEFAULT 100,
    calories NUMERIC(6, 2) NOT NULL,
    protein_grams NUMERIC(5, 2) NOT NULL DEFAULT 0,
    carbs_grams NUMERIC(5, 2) NOT NULL DEFAULT 0,
    fats_grams NUMERIC(5, 2) NOT NULL DEFAULT 0
);

-- 6. Meal Logs Table (Daily Nutrition Tracking)
CREATE TABLE IF NOT EXISTS meal_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    food_item_id UUID REFERENCES food_items(id) ON DELETE RESTRICT,
    servings_consumed NUMERIC(5, 2) NOT NULL DEFAULT 1.0,
    meal_type VARCHAR(30) NOT NULL, -- e.g., Breakfast, Lunch, Dinner, Snack
    logged_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Seed initial common exercises
INSERT INTO exercises (name, target_muscle, equipment_required) VALUES
('Bench Press', 'Chest', 'Barbell'),
('Incline Dumbbell Press', 'Chest', 'Dumbbells'),
('Squat', 'Quads', 'Barbell'),
('Deadlift', 'Hamstrings/Back', 'Barbell'),
('Overhead Press', 'Shoulders', 'Barbell'),
('Pull-up', 'Lats', 'Pull-up Bar'),
('Barbell Row', 'Upper Back', 'Barbell'),
('Bicep Curl', 'Biceps', 'Dumbbells'),
('Tricep Pushdown', 'Triceps', 'Cable')
ON CONFLICT (name) DO NOTHING;

-- Seed staple nutritional items (per 100g serving)
INSERT INTO food_items (name, serving_size_grams, calories, protein_grams, carbs_grams, fats_grams) VALUES
('Injera', 100, 161, 3.9, 34.0, 0.7),
('Cooked Rice', 100, 130, 2.7, 28.0, 0.3),
('Soya Chunks (dry)', 100, 345, 52.0, 33.0, 0.5),
('Egg (Boiled)', 100, 155, 12.6, 1.1, 10.6),
('Peanut Butter', 100, 588, 25.0, 20.0, 50.0),
('Avocado', 100, 160, 2.0, 8.5, 14.7),
('Chicken Breast (Cooked)', 100, 165, 31.0, 0.0, 3.6),
('Lentils / Misir (Cooked)', 100, 116, 9.0, 20.0, 0.4)
ON CONFLICT (name) DO NOTHING;
