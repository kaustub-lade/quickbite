const https = require('https');
const http = require('http');

async function login() {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify({
      email: 'kaustub@example.com',
      password: 'customer123'
    });

    const options = {
      hostname: 'localhost',
      port: 3000,
      path: '/api/auth/login',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': data.length
      }
    };

    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        try {
          console.log('Login response status:', res.statusCode);
          console.log('Login response body:', body);
          const response = JSON.parse(body);
          if (response.token) {
            resolve(response.token);
          } else if (response.data && response.data.token) {
            resolve(response.data.token);
          } else {
            reject(new Error('No token in response: ' + body));
          }
        } catch (e) {
          reject(e);
        }
      });
    });

    req.on('error', reject);
    req.write(data);
    req.end();
  });
}

async function testScraper(token) {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify({
      restaurantId: '698c76a41edd1a6def8ab181',
      restaurantName: 'Paradise Biryani',
      restaurantSlug: 'kfc-kurla-west-rest243517',
      forceRefresh: true
    });

    const options = {
      hostname: 'localhost',
      port: 3000,
      path: '/api/scrape/swiggy',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': data.length,
        'Authorization': `Bearer ${token}`
      }
    };

    console.log('\n🔍 Testing Swiggy scraper...');
    console.log('URL: http://localhost:3000/api/scrape/swiggy');
    console.log('Restaurant: KFC Kurla West');
    console.log('Slug: kfc-kurla-west-rest243517\n');

    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        try {
          const response = JSON.parse(body);
          console.log('✅ Response Status:', res.statusCode);
          console.log('\n📊 Response Data:');
          console.log(JSON.stringify(response, null, 2));
          resolve(response);
        } catch (e) {
          console.error('❌ Parse Error:', e.message);
          console.log('Raw Response:', body);
          reject(e);
        }
      });
    });

    req.on('error', (e) => {
      console.error('❌ Request Error:', e.message);
      reject(e);
    });

    req.write(data);
    req.end();
  });
}

async function main() {
  try {
    console.log('🔐 Logging in...');
    const token = await login();
    console.log('✅ Got JWT token (length:', token.length, 'chars)\n');

    const result = await testScraper(token);
    
    if (result.success) {
      console.log('\n🎉 SCRAPER TEST SUCCESSFUL!');
      console.log('Items scraped:', result.data?.menuItems?.length || 0);
      console.log('Scrape method:', result.data?.scrapeMethod || 'unknown');
    } else {
      console.log('\n⚠️  Scraper returned success: false');
      console.log('Message:', result.message);
    }
  } catch (error) {
    console.error('\n❌ Test failed:', error.message);
    process.exit(1);
  }
}

main();
