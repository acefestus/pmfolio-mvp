/*
  # Create users table for PMfolio

  1. New Tables
    - `users`
      - `id` (uuid, primary key) - User identifier
      - `email` (text, unique) - User email address
      - `full_name` (text) - User's full name
      - `title` (text) - Professional title (e.g., "Senior Product Manager")
      - `bio` (text) - User biography/description
      - `avatar_url` (text) - Profile picture URL
      - `linkedin_url` (text) - LinkedIn profile URL
      - `portfolio_url` (text) - Personal portfolio website URL
      - `location` (text) - User location
      - `years_experience` (integer) - Years of PM experience
      - `created_at` (timestamp) - Account creation timestamp
      - `updated_at` (timestamp) - Last profile update timestamp

  2. Security
    - Enable RLS on `users` table
    - Add policy for users to read all profiles (public visibility)
    - Add policy for authenticated users to update their own profile
*/

CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  full_name text NOT NULL DEFAULT '',
  title text DEFAULT '',
  bio text DEFAULT '',
  avatar_url text DEFAULT '',
  linkedin_url text DEFAULT '',
  portfolio_url text DEFAULT '',
  location text DEFAULT '',
  years_experience integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Allow anyone to read user profiles (public visibility)
CREATE POLICY "Users can read all profiles"
  ON users
  FOR SELECT
  TO authenticated, anon
  USING (true);

-- Allow users to update their own profile
CREATE POLICY "Users can update own profile"
  ON users
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id);

-- Allow users to insert their own profile
CREATE POLICY "Users can insert own profile"
  ON users
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();