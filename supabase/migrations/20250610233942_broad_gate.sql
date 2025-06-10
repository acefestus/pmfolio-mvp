/*
  # Create recommendations table for PMfolio

  1. New Tables
    - `recommendations`
      - `id` (uuid, primary key) - Recommendation identifier
      - `user_id` (uuid, foreign key) - User receiving the recommendation
      - `recommender_name` (text) - Name of person giving recommendation
      - `recommender_title` (text) - Title of recommender
      - `recommender_company` (text) - Company of recommender
      - `recommender_email` (text) - Email of recommender (optional)
      - `recommender_linkedin` (text) - LinkedIn profile of recommender
      - `relationship` (text) - Relationship to user (manager, colleague, etc.)
      - `recommendation_text` (text) - The actual recommendation content
      - `skills_highlighted` (text array) - Key skills mentioned
      - `project_context` (text) - Context/project the recommendation relates to
      - `status` (text) - Status (pending, approved, rejected)
      - `is_featured` (boolean) - Whether to feature prominently
      - `created_at` (timestamp) - Recommendation creation timestamp
      - `updated_at` (timestamp) - Last update timestamp

  2. Security
    - Enable RLS on `recommendations` table
    - Add policy for anyone to read approved recommendations
    - Add policy for users to manage their own recommendations
*/

CREATE TABLE IF NOT EXISTS recommendations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  recommender_name text NOT NULL,
  recommender_title text DEFAULT '',
  recommender_company text DEFAULT '',
  recommender_email text DEFAULT '',
  recommender_linkedin text DEFAULT '',
  relationship text DEFAULT '',
  recommendation_text text NOT NULL,
  skills_highlighted text[] DEFAULT '{}',
  project_context text DEFAULT '',
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  is_featured boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE recommendations ENABLE ROW LEVEL SECURITY;

-- Allow anyone to read approved recommendations
CREATE POLICY "Anyone can read approved recommendations"
  ON recommendations
  FOR SELECT
  TO authenticated, anon
  USING (status = 'approved');

-- Allow users to read their own recommendations (all statuses)
CREATE POLICY "Users can read own recommendations"
  ON recommendations
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Allow users to insert their own recommendations
CREATE POLICY "Users can insert own recommendations"
  ON recommendations
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Allow users to update their own recommendations
CREATE POLICY "Users can update own recommendations"
  ON recommendations
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);

-- Allow users to delete their own recommendations
CREATE POLICY "Users can delete own recommendations"
  ON recommendations
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_recommendations_updated_at
  BEFORE UPDATE ON recommendations
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS recommendations_user_id_idx ON recommendations(user_id);
CREATE INDEX IF NOT EXISTS recommendations_status_idx ON recommendations(status);
CREATE INDEX IF NOT EXISTS recommendations_featured_idx ON recommendations(is_featured);