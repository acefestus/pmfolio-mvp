/*
  # Create projects table for PMfolio

  1. New Tables
    - `projects`
      - `id` (uuid, primary key) - Project identifier
      - `user_id` (uuid, foreign key) - Reference to users table
      - `title` (text) - Project title
      - `description` (text) - Project description
      - `problem_statement` (text) - Problem the project solved
      - `solution_overview` (text) - High-level solution description
      - `impact_metrics` (text) - Key metrics and results achieved
      - `technologies_used` (text array) - Technologies/tools used
      - `role` (text) - User's role in the project
      - `team_size` (integer) - Size of the project team
      - `duration_months` (integer) - Project duration in months
      - `company` (text) - Company where project was executed
      - `project_url` (text) - Link to live project or case study
      - `image_urls` (text array) - Project screenshots/images
      - `status` (text) - Project status (draft, published, archived)
      - `featured` (boolean) - Whether project is featured
      - `created_at` (timestamp) - Project creation timestamp
      - `updated_at` (timestamp) - Last project update timestamp

  2. Security
    - Enable RLS on `projects` table
    - Add policy for anyone to read published projects
    - Add policy for users to manage their own projects
*/

CREATE TABLE IF NOT EXISTS projects (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  title text NOT NULL,
  description text DEFAULT '',
  problem_statement text DEFAULT '',
  solution_overview text DEFAULT '',
  impact_metrics text DEFAULT '',
  technologies_used text[] DEFAULT '{}',
  role text DEFAULT '',
  team_size integer DEFAULT 1,
  duration_months integer DEFAULT 1,
  company text DEFAULT '',
  project_url text DEFAULT '',
  image_urls text[] DEFAULT '{}',
  status text DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived')),
  featured boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

-- Allow anyone to read published projects
CREATE POLICY "Anyone can read published projects"
  ON projects
  FOR SELECT
  TO authenticated, anon
  USING (status = 'published');

-- Allow users to read their own projects (all statuses)
CREATE POLICY "Users can read own projects"
  ON projects
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Allow users to insert their own projects
CREATE POLICY "Users can insert own projects"
  ON projects
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Allow users to update their own projects
CREATE POLICY "Users can update own projects"
  ON projects
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);

-- Allow users to delete their own projects
CREATE POLICY "Users can delete own projects"
  ON projects
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_projects_updated_at
  BEFORE UPDATE ON projects
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Create index for better query performance
CREATE INDEX IF NOT EXISTS projects_user_id_idx ON projects(user_id);
CREATE INDEX IF NOT EXISTS projects_status_idx ON projects(status);
CREATE INDEX IF NOT EXISTS projects_featured_idx ON projects(featured);