/*
  # Update collections schema to match new requirements

  1. Table Updates
    - Update `users` table:
      - Add `username` (text, unique) - Slug field for user URLs
      - Add `skills` (text array) - Multi-select skills
      - Add `tools_used` (text array) - Multi-select tools
      - Add `template_choice` (text) - Select template option
      - Rename `full_name` to `name`
      - Rename `avatar_url` to `profile_image`
      - Remove unused fields for cleaner structure

    - Update `projects` table:
      - Rename `problem_statement` to `problem`
      - Rename `solution_overview` to `solution`
      - Rename `impact_metrics` to `results`
      - Rename `image_urls` to `images`
      - Remove unused fields for cleaner structure

    - Update `recommendations` table:
      - Rename `recommender_name` to `name`
      - Rename `recommender_title` to `role`
      - Rename `recommendation_text` to `quote`
      - Add `linked_project` (uuid) - Relation to Projects
      - Remove unused fields for cleaner structure

  2. Security
    - Maintain existing RLS policies
    - Update policies to work with new field names
*/

-- Update users table structure
DO $$
BEGIN
  -- Add new columns if they don't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'users' AND column_name = 'username'
  ) THEN
    ALTER TABLE users ADD COLUMN username text UNIQUE;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'users' AND column_name = 'skills'
  ) THEN
    ALTER TABLE users ADD COLUMN skills text[] DEFAULT '{}';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'users' AND column_name = 'tools_used'
  ) THEN
    ALTER TABLE users ADD COLUMN tools_used text[] DEFAULT '{}';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'users' AND column_name = 'template_choice'
  ) THEN
    ALTER TABLE users ADD COLUMN template_choice text DEFAULT 'default';
  END IF;

  -- Rename columns (only if old column exists and new doesn't)
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'users' AND column_name = 'full_name'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'users' AND column_name = 'name'
  ) THEN
    ALTER TABLE users RENAME COLUMN full_name TO name;
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'users' AND column_name = 'avatar_url'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'users' AND column_name = 'profile_image'
  ) THEN
    ALTER TABLE users RENAME COLUMN avatar_url TO profile_image;
  END IF;
END $$;

-- Update projects table structure
DO $$
BEGIN
  -- Rename columns (only if old column exists and new doesn't)
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'projects' AND column_name = 'problem_statement'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'projects' AND column_name = 'problem'
  ) THEN
    ALTER TABLE projects RENAME COLUMN problem_statement TO problem;
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'projects' AND column_name = 'solution_overview'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'projects' AND column_name = 'solution'
  ) THEN
    ALTER TABLE projects RENAME COLUMN solution_overview TO solution;
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'projects' AND column_name = 'impact_metrics'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'projects' AND column_name = 'results'
  ) THEN
    ALTER TABLE projects RENAME COLUMN impact_metrics TO results;
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'projects' AND column_name = 'image_urls'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'projects' AND column_name = 'images'
  ) THEN
    ALTER TABLE projects RENAME COLUMN image_urls TO images;
  END IF;
END $$;

-- Update recommendations table structure
DO $$
BEGIN
  -- Add new columns if they don't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'recommendations' AND column_name = 'linked_project'
  ) THEN
    ALTER TABLE recommendations ADD COLUMN linked_project uuid REFERENCES projects(id) ON DELETE SET NULL;
  END IF;

  -- Rename columns (only if old column exists and new doesn't)
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'recommendations' AND column_name = 'recommender_name'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'recommendations' AND column_name = 'name'
  ) THEN
    ALTER TABLE recommendations RENAME COLUMN recommender_name TO name;
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'recommendations' AND column_name = 'recommender_title'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'recommendations' AND column_name = 'role'
  ) THEN
    ALTER TABLE recommendations RENAME COLUMN recommender_title TO role;
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'recommendations' AND column_name = 'recommendation_text'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'recommendations' AND column_name = 'quote'
  ) THEN
    ALTER TABLE recommendations RENAME COLUMN recommendation_text TO quote;
  END IF;
END $$;

-- Create index for username lookups
CREATE INDEX IF NOT EXISTS users_username_idx ON users(username);

-- Create index for linked projects in recommendations
CREATE INDEX IF NOT EXISTS recommendations_linked_project_idx ON recommendations(linked_project);