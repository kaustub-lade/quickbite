const https = require('https');

async function testFoodSparks() {
  const testUrls = [
    'https://foodsparks.in/',
    'https://www.foodsparks.in/',
    'https://foodsparks.com/',
  ];
  
  console.log('🔍 Testing FoodSparks URLs...\n');
  
  for (const url of testUrls) {
    await testUrl(url);
    console.log('\n' + '='.repeat(80) + '\n');
  }
}

async function testUrl(url) {
  return new Promise((resolve) => {
    const jinaUrl = `https://r.jina.ai/${url}`;
    
    console.log(`Testing: ${url}`);
    console.log(`Via Jina: ${jinaUrl}`);
    
    const startTime = Date.now();
    
    https.get(jinaUrl, {
      headers: {
        'Accept': 'text/plain',
        'X-Return-Format': 'markdown'
      }
    }, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        const duration = Date.now() - startTime;
        
        console.log(`✅ Response in ${duration}ms`);
        console.log(`Length: ${body.length} characters`);
        
        // Check for indicators of food delivery data
        const indicators = {
          'swiggy': body.toLowerCase().includes('swiggy'),
          'zomato': body.toLowerCase().includes('zomato'),
          'menu': body.toLowerCase().includes('menu'),
          'restaurant': body.toLowerCase().includes('restaurant'),
          'food': body.toLowerCase().includes('food'),
          'price': body.includes('₹') || body.toLowerCase().includes('price'),
          'delivery': body.toLowerCase().includes('delivery')
        };
        
        console.log('\n📊 Content Analysis:');
        Object.entries(indicators).forEach(([key, found]) => {
          console.log(`  ${key}: ${found ? '✅' : '❌'}`);
        });
        
        const foundCount = Object.values(indicators).filter(v => v).length;
        console.log(`\nRelevance Score: ${foundCount}/7`);
        
        if (foundCount >= 4) {
          console.log('✅ Potentially useful for food delivery data!');
        } else {
          console.log('⚠️ Limited food delivery relevance');
        }
        
        // Show first 2000 chars
        console.log('\n📄 First 2000 characters:');
        console.log('-'.repeat(80));
        console.log(body.substring(0, 2000));
        console.log('-'.repeat(80));
        
        // Look for URLs or API endpoints
        const urlPattern = /(https?:\/\/[^\s\)]+)/g;
        const urls = body.match(urlPattern) || [];
        const uniqueUrls = [...new Set(urls)].filter(u => 
          u.includes('swiggy') || u.includes('zomato') || u.includes('api')
        ).slice(0, 10);
        
        if (uniqueUrls.length > 0) {
          console.log('\n🔗 Interesting URLs found:');
          uniqueUrls.forEach(url => console.log(`  - ${url}`));
        }
        
        resolve();
      });
    }).on('error', (error) => {
      console.error(`❌ Error: ${error.message}`);
      resolve();
    });
  });
}

testFoodSparks();
