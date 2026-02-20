export default function HomePage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-orange-500 to-red-600 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl shadow-2xl p-8 max-w-md w-full">
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold text-gray-800 mb-2">🍔 QuickBite</h1>
          <p className="text-gray-600">Smart Food Ordering Platform</p>
        </div>

        <div className="space-y-4">
          <a
            href="/admin/login"
            className="block w-full bg-gradient-to-r from-orange-500 to-red-600 text-white py-3 px-6 rounded-lg font-medium text-center hover:shadow-lg transition-shadow"
          >
            👑 Admin Dashboard
          </a>

          <div className="bg-gray-50 p-4 rounded-lg">
            <p className="text-sm text-gray-600 mb-2">📱 Mobile App</p>
            <p className="text-xs text-gray-500">
              Download the QuickBite mobile app to order food from your favorite restaurants
            </p>
          </div>

          <div className="border-t pt-4 mt-4">
            <p className="text-xs text-gray-500 text-center">
              Platform for comparing prices across Swiggy, Zomato, and ONDC
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
