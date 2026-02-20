'use client'

import { useEffect, useState } from 'react'

export default function RestaurantsPage() {
  const [restaurants, setRestaurants] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  useEffect(() => {
    fetchRestaurants()
  }, [])

  const fetchRestaurants = async () => {
    try {
      const token = localStorage.getItem('admin_token')
      const response = await fetch('/api/admin/restaurants', {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })

      const data = await response.json()

      if (data.success) {
        setRestaurants(data.data.restaurants)
      } else {
        setError(data.message || 'Failed to load restaurants')
      }
    } catch (err) {
      setError('Failed to connect to server')
    } finally {
      setLoading(false)
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-orange-600"></div>
      </div>
    )
  }

  return (
    <div>
      <div className="mb-8 flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Restaurants</h1>
          <p className="text-gray-500 mt-1">Manage all restaurants on the platform</p>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <div className="bg-white rounded-lg shadow p-6">
          <div className="text-2xl font-bold text-orange-600">
            {restaurants.length}
          </div>
          <div className="text-gray-600 text-sm">Total Restaurants</div>
        </div>
        <div className="bg-white rounded-lg shadow p-6">
          <div className="text-2xl font-bold text-green-600">
            {restaurants.length}
          </div>
          <div className="text-gray-600 text-sm">Active</div>
        </div>
        <div className="bg-white rounded-lg shadow p-6">
          <div className="text-2xl font-bold text-blue-600">
            {new Set(restaurants.map((r) => r.cuisine)).size}
          </div>
          <div className="text-gray-600 text-sm">Cuisines</div>
        </div>
      </div>

      {/* Restaurants Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {restaurants.map((restaurant) => (
          <div
            key={restaurant._id}
            className="bg-white rounded-lg shadow hover:shadow-lg transition overflow-hidden"
          >
            {restaurant.imageUrl ? (
              <img
                src={restaurant.imageUrl}
                alt={restaurant.name}
                className="w-full h-48 object-cover"
              />
            ) : (
              <div className="w-full h-48 bg-gradient-to-br from-orange-400 to-red-500 flex items-center justify-center">
                <span className="text-6xl">{restaurant.name[0]}</span>
              </div>
            )}

            <div className="p-6">
              <h3 className="text-xl font-bold text-gray-900 mb-2">
                {restaurant.name}
              </h3>

              <div className="space-y-2 text-sm text-gray-600">
                <div className="flex items-center">
                  <span className="mr-2">🍽️</span>
                  <span>{restaurant.cuisine}</span>
                </div>

                <div className="flex items-center">
                  <span className="mr-2">📍</span>
                  <span>{restaurant.location}</span>
                </div>

                <div className="flex items-center">
                  <span className="mr-2">⭐</span>
                  <span>{restaurant.rating?.toFixed(1) || 'N/A'}</span>
                </div>

                <div className="flex items-center">
                  <span className="mr-2">🔑</span>
                  <span className="font-mono text-xs">{restaurant.id}</span>
                </div>
              </div>

              <div className="mt-4 pt-4 border-t">
                <div className="text-xs text-gray-500">
                  Added {new Date(restaurant.createdAt).toLocaleDateString()}
                </div>
              </div>
            </div>
          </div>
        ))}

        {restaurants.length === 0 && (
          <div className="col-span-full text-center py-12 text-gray-500 bg-white rounded-lg shadow">
            No restaurants found. Run seed script to add restaurants.
            <div className="mt-4">
              <code className="bg-gray-100 px-4 py-2 rounded text-sm">
                npm run seed
              </code>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
