import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables')
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

// Helper functions for database operations

// Users
export const getUser = async (userId) => {
  const { data, error } = await supabase
    .from('users')
    .select('*')
    .eq('id', userId)
    .single()
  
  return { data, error }
}

export const getUserByEmail = async (email) => {
  const { data, error } = await supabase
    .from('users')
    .select('*')
    .eq('email', email)
    .single()
  
  return { data, error }
}

export const getUserByUsername = async (username) => {
  // For now, we'll use email as username
  // You can add a separate username field later
  const { data, error } = await supabase
    .from('users')
    .select('*')
    .eq('email', `${username}@example.com`)
    .single()
  
  return { data, error }
}

export const updateUser = async (userId, updates) => {
  const { data, error } = await supabase
    .from('users')
    .update(updates)
    .eq('id', userId)
    .select()
    .single()
  
  return { data, error }
}

// Projects
export const getUserProjects = async (userId, status = 'published') => {
  let query = supabase
    .from('projects')
    .select('*')
    .eq('user_id', userId)
    .order('created_at', { ascending: false })
  
  if (status) {
    query = query.eq('status', status)
  }
  
  const { data, error } = await query
  return { data, error }
}

export const getFeaturedProjects = async (limit = 6) => {
  const { data, error } = await supabase
    .from('projects')
    .select(`
      *,
      users (
        full_name,
        title,
        avatar_url
      )
    `)
    .eq('status', 'published')
    .eq('featured', true)
    .order('created_at', { ascending: false })
    .limit(limit)
  
  return { data, error }
}

export const createProject = async (projectData) => {
  const { data, error } = await supabase
    .from('projects')
    .insert([projectData])
    .select()
    .single()
  
  return { data, error }
}

export const updateProject = async (projectId, updates) => {
  const { data, error } = await supabase
    .from('projects')
    .update(updates)
    .eq('id', projectId)
    .select()
    .single()
  
  return { data, error }
}

// Recommendations
export const getUserRecommendations = async (userId, status = 'approved') => {
  let query = supabase
    .from('recommendations')
    .select('*')
    .eq('user_id', userId)
    .order('created_at', { ascending: false })
  
  if (status) {
    query = query.eq('status', status)
  }
  
  const { data, error } = await query
  return { data, error }
}

export const createRecommendation = async (recommendationData) => {
  const { data, error } = await supabase
    .from('recommendations')
    .insert([recommendationData])
    .select()
    .single()
  
  return { data, error }
}

export const updateRecommendation = async (recommendationId, updates) => {
  const { data, error } = await supabase
    .from('recommendations')
    .update(updates)
    .eq('id', recommendationId)
    .select()
    .single()
  
  return { data, error }
}