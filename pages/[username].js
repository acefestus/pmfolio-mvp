import { useState, useEffect } from 'react'
import { useRouter } from 'next/router'
import { supabase } from '../lib/supabaseClient'
import Head from 'next/head'

export default function UserProfile() {
  const router = useRouter()
  const { username } = router.query
  const [user, setUser] = useState(null)
  const [projects, setProjects] = useState([])
  const [recommendations, setRecommendations] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    if (username) {
      fetchUserData()
    }
  }, [username])

  const fetchUserData = async () => {
    try {
      setLoading(true)
      
      // Fetch user by email (using email as username for now)
      const { data: userData, error: userError } = await supabase
        .from('users')
        .select('*')
        .eq('email', `${username}@example.com`) // You can modify this logic
        .single()

      if (userError && userError.code !== 'PGRST116') {
        throw userError
      }

      if (!userData) {
        setError('User not found')
        setLoading(false)
        return
      }

      setUser(userData)

      // Fetch user's published projects
      const { data: projectsData, error: projectsError } = await supabase
        .from('projects')
        .select('*')
        .eq('user_id', userData.id)
        .eq('status', 'published')
        .order('created_at', { ascending: false })

      if (projectsError) throw projectsError
      setProjects(projectsData || [])

      // Fetch user's approved recommendations
      const { data: recommendationsData, error: recommendationsError } = await supabase
        .from('recommendations')
        .select('*')
        .eq('user_id', userData.id)
        .eq('status', 'approved')
        .order('created_at', { ascending: false })

      if (recommendationsError) throw recommendationsError
      setRecommendations(recommendationsData || [])

    } catch (err) {
      console.error('Error fetching user data:', err)
      setError('Failed to load user profile')
    } finally {
      setLoading(false)
    }
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading profile...</p>
        </div>
      </div>
    )
  }

  if (error || !user) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <h1 className="text-4xl font-bold text-gray-900 mb-4">404</h1>
          <p className="text-xl text-gray-600 mb-8">{error || 'User not found'}</p>
          <button
            onClick={() => router.push('/')}
            className="bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 transition-colors"
          >
            Go Home
          </button>
        </div>
      </div>
    )
  }

  return (
    <>
      <Head>
        <title>{user.full_name} - PMfolio</title>
        <meta name="description" content={user.bio} />
      </Head>

      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <header className="bg-white shadow-sm">
          <div className="max-w-6xl mx-auto px-4 py-6">
            <div className="flex items-center justify-between">
              <h1 className="text-2xl font-bold text-gray-900">PMfolio</h1>
              <button
                onClick={() => router.push('/')}
                className="text-blue-600 hover:text-blue-700 font-medium"
              >
                ← Back to Home
              </button>
            </div>
          </div>
        </header>

        {/* Profile Section */}
        <section className="bg-white">
          <div className="max-w-6xl mx-auto px-4 py-12">
            <div className="flex flex-col md:flex-row items-start gap-8">
              {/* Avatar */}
              <div className="flex-shrink-0">
                {user.avatar_url ? (
                  <img
                    src={user.avatar_url}
                    alt={user.full_name}
                    className="w-32 h-32 rounded-full object-cover border-4 border-gray-200"
                  />
                ) : (
                  <div className="w-32 h-32 rounded-full bg-blue-600 flex items-center justify-center text-white text-4xl font-bold">
                    {user.full_name.charAt(0)}
                  </div>
                )}
              </div>

              {/* Profile Info */}
              <div className="flex-1">
                <h1 className="text-4xl font-bold text-gray-900 mb-2">{user.full_name}</h1>
                <p className="text-xl text-blue-600 mb-4">{user.title}</p>
                
                <div className="flex flex-wrap gap-4 mb-6 text-gray-600">
                  {user.location && (
                    <span className="flex items-center gap-1">
                      📍 {user.location}
                    </span>
                  )}
                  {user.years_experience > 0 && (
                    <span className="flex items-center gap-1">
                      💼 {user.years_experience} years experience
                    </span>
                  )}
                </div>

                {user.bio && (
                  <p className="text-gray-700 text-lg leading-relaxed mb-6">{user.bio}</p>
                )}

                {/* Links */}
                <div className="flex flex-wrap gap-4">
                  {user.linkedin_url && (
                    <a
                      href={user.linkedin_url}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors"
                    >
                      LinkedIn
                    </a>
                  )}
                  {user.portfolio_url && (
                    <a
                      href={user.portfolio_url}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="bg-gray-800 text-white px-4 py-2 rounded-lg hover:bg-gray-900 transition-colors"
                    >
                      Portfolio
                    </a>
                  )}
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Projects Section */}
        <section className="py-12">
          <div className="max-w-6xl mx-auto px-4">
            <h2 className="text-3xl font-bold text-gray-900 mb-8">Projects</h2>
            
            {projects.length > 0 ? (
              <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
                {projects.map((project) => (
                  <div key={project.id} className="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-shadow">
                    {project.image_urls && project.image_urls.length > 0 && (
                      <img
                        src={project.image_urls[0]}
                        alt={project.title}
                        className="w-full h-48 object-cover"
                      />
                    )}
                    <div className="p-6">
                      <h3 className="text-xl font-bold text-gray-900 mb-2">{project.title}</h3>
                      <p className="text-gray-600 mb-4 line-clamp-3">{project.description}</p>
                      
                      <div className="flex flex-wrap gap-2 mb-4">
                        {project.technologies_used && project.technologies_used.slice(0, 3).map((tech, index) => (
                          <span key={index} className="bg-blue-100 text-blue-800 px-2 py-1 rounded text-sm">
                            {tech}
                          </span>
                        ))}
                      </div>

                      <div className="flex justify-between items-center text-sm text-gray-500">
                        <span>{project.company}</span>
                        <span>{project.duration_months} months</span>
                      </div>

                      {project.project_url && (
                        <a
                          href={project.project_url}
                          target="_blank"
                          rel="noopener noreferrer"
                          className="inline-block mt-4 text-blue-600 hover:text-blue-700 font-medium"
                        >
                          View Project →
                        </a>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <div className="text-center py-12">
                <p className="text-gray-500 text-lg">No projects published yet.</p>
              </div>
            )}
          </div>
        </section>

        {/* Recommendations Section */}
        {recommendations.length > 0 && (
          <section className="py-12 bg-gray-100">
            <div className="max-w-6xl mx-auto px-4">
              <h2 className="text-3xl font-bold text-gray-900 mb-8">Recommendations</h2>
              
              <div className="grid md:grid-cols-2 gap-8">
                {recommendations.map((rec) => (
                  <div key={rec.id} className="bg-white rounded-lg shadow-md p-6">
                    <blockquote className="text-gray-700 text-lg leading-relaxed mb-4">
                      "{rec.recommendation_text}"
                    </blockquote>
                    
                    <div className="border-t pt-4">
                      <div className="flex items-center justify-between">
                        <div>
                          <p className="font-semibold text-gray-900">{rec.recommender_name}</p>
                          <p className="text-gray-600">{rec.recommender_title}</p>
                          {rec.recommender_company && (
                            <p className="text-gray-500">{rec.recommender_company}</p>
                          )}
                        </div>
                        {rec.recommender_linkedin && (
                          <a
                            href={rec.recommender_linkedin}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="text-blue-600 hover:text-blue-700"
                          >
                            LinkedIn
                          </a>
                        )}
                      </div>
                      
                      {rec.skills_highlighted && rec.skills_highlighted.length > 0 && (
                        <div className="mt-4">
                          <p className="text-sm text-gray-500 mb-2">Skills highlighted:</p>
                          <div className="flex flex-wrap gap-2">
                            {rec.skills_highlighted.map((skill, index) => (
                              <span key={index} className="bg-green-100 text-green-800 px-2 py-1 rounded text-sm">
                                {skill}
                              </span>
                            ))}
                          </div>
                        </div>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </section>
        )}

        {/* Footer */}
        <footer className="bg-white border-t py-8">
          <div className="max-w-6xl mx-auto px-4 text-center text-gray-600">
            <p>© 2025 PMfolio. Showcasing Product Management Excellence.</p>
          </div>
        </footer>
      </div>
    </>
  )
}