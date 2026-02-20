'use client'

import { useEffect, useState } from 'react'

export default function MenuPage() {
  const [menuItems, setMenuItems] = useState<any[]>([])
  const [restaurants, setRestaurants] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [filter, setFilter] = useState('all')
  const [user, setUser] = useState<any>(null)

  useEffect(() => {
    const userData = localStorage.getItem('admin_user')
    if (userData) {
      setUser(JSON.parse(userData))
    }
    fetchData()
  }, [filter])

  const fetchData = async () => {
    try {
      const token = localStorage.getItem('admin_token')

      // Fetch menu items
      const url =
        filter === 'all'
          ? '/api/admin/menu'
          : `/api/admin/menu?restaurantId=${filter}`

      const menuResponse = await fetch(url, {
        headers: { Authorization: `Bearer ${token}` },
      })
      const menuData = await menuResponse.json()

      if (menuData.success) {
        setMenuItems(menuData.data.menuItems)
      }

      // Fetch restaurants (admin only)
      if (user?.role === 'admin') {
        const restResponse = await fetch('/api/admin/restaurants', {
          headers: { Authorization: `Bearer ${token}` },
        })
        const restData = await restResponse.json()

        if (restData.success) {
          setRestaurants(restData.data.restaurants)
        }
      }
    } catch (err) {
      console.error('Error fetching data:', err)
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

  // Group menu items by restaurant
  const groupedItems = menuItems.reduce((acc: any, item) => {
    if (!acc[item.restaurantId]) {
      acc[item.restaurantId] = []
    }
    acc[item.restaurantId].push(item)
    return acc
  }, {})

  return (
    <div>
      <div className="mb-8 flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Menu Management</h1>
          <p className="text-gray-500 mt-1">
            {user?.role === 'admin'
              ? 'Manage menu items for all restaurants'
              : `Manage menu for ${user?.restaurantId}`}
          </p>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <div className="bg-white rounded-lg shadow p-6">
          <div className="text-2xl font-bold text-orange-600">
            {menuItems.length}
          </div>
          <div className="text-gray-600 text-sm">Total Menu Items</div>
        </div>
        <div className="bg-white rounded-lg shadow p-6">
          <div className="text-2xl font-bold text-green-600">
            {menuItems.filter((item) => item.isAvailable).length}
          </div>
          <div className="text-gray-600 text-sm">Available</div>
        </div>
        <div className="bg-white rounded-lg shadow p-6">
          <div className="text-2xl font-bold text-blue-600">
            {menuItems.filter((item) => item.isVeg).length}
          </div>
          <div className="text-gray-600 text-sm">Vegetarian</div>
        </div>
      </div>

      {/* Filter */}
      {user?.role === 'admin' && restaurants.length > 0 && (
        <div className="mb-6 flex space-x-2">
          <button
            onClick={() => setFilter('all')}
            className={`px-4 py-2 rounded-lg font-medium transition ${
              filter === 'all'
                ? 'bg-orange-600 text-white'
                : 'bg-white text-gray-700 hover:bg-gray-50 border'
            }`}
          >
            All Restaurants
          </button>
          {restaurants.map((restaurant) => (
            <button
              key={restaurant.id}
              onClick={() => setFilter(restaurant.id)}
              className={`px-4 py-2 rounded-lg font-medium transition ${
                filter === restaurant.id
                  ? 'bg-orange-600 text-white'
                  : 'bg-white text-gray-700 hover:bg-gray-50 border'
              }`}
            >
              {restaurant.name}
            </button>
          ))}
        </div>
      )}

      {/* Menu Items by Restaurant */}
      <div className="space-y-8">
        {Object.keys(groupedItems).map((restaurantId) => (
          <div key={restaurantId} className="bg-white rounded-lg shadow overflow-hidden">
            <div className="bg-gray-50 px-6 py-4 border-b">
              <h2 className="text-xl font-semibold text-gray-900 capitalize">
                {restaurantId.replace(/-/g, ' ')}
              </h2>
              <p className="text-sm text-gray-500">
                {groupedItems[restaurantId].length} items
              </p>
            </div>

            <div className="divide-y divide-gray-200">
              {groupedItems[restaurantId].map((item: any) => (
                <div key={item._id} className="p-6 hover:bg-gray-50">
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <div className="flex items-center space-x-3">
                        <div
                          className={`w-4 h-4 rounded-full flex-shrink-0 ${
                            item.isVeg ? 'bg-green-500' : 'bg-red-500'
                          }`}
                        ></div>
                        <h3 className="text-lg font-semibold text-gray-900">
                          {item.name}
                        </h3>
                        {!item.isAvailable && (
                          <span className="px-2 py-1 text-xs font-semibold rounded-full bg-red-100 text-red-800">
                            Unavailable
                          </span>
                        )}
                      </div>
                      <p className="text-gray-600 text-sm mt-2">
                        {item.description}
                      </p>
                      <div className="flex items-center space-x-4 mt-3 text-sm text-gray-500">
                        <span className="font-semibold text-green-600">
                          ₹{item.price}
                        </span>
                        <span>•</span>
                        <span>{item.category}</span>
                        {item.preparationTime && (
                          <>
                            <span>•</span>
                            <span>{item.preparationTime} mins</span>
                          </>
                        )}
                        {item.spiceLevel && (
                          <>
                            <span>•</span>
                            <span className="capitalize">{item.spiceLevel}</span>
                          </>
                        )}
                      </div>
                    </div>

                    {item.imageUrl && (
                      <img
                        src={item.imageUrl}
                        alt={item.name}
                        className="w-24 h-24 object-cover rounded-lg ml-4"
                      />
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>
        ))}

        {menuItems.length === 0 && (
          <div className="text-center py-12 text-gray-500 bg-white rounded-lg shadow">
            No menu items found. Run seed script to add menu items.
            <div className="mt-4">
              <code className="bg-gray-100 px-4 py-2 rounded text-sm">
                npm run seed:menu
              </code>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
