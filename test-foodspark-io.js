const https = require('https');

async function testFoodSparkIO() {
  const urls = [
    'https://www.foodspark.io/',
    'https://www.foodspark.io/restaurant-menu-data-scraping/',
    'https://www.foodspark.io/pricing',
    'https://www.foodspark.io/api',
  ];
  
  console.log('🔍 Testing FoodSpark.io - Restaurant Menu Data Scraping Service\n');
  console.log('='.repeat(80) + '\n');
  
  for (const url of urls) {
    await testUrl(url);
    console.log('\n' + '='.repeat(80) + '\n');
    await new Promise(resolve => setTimeout(resolve, 2000));
  }
}

async function testUrl(url) {
  return new Promise((resolve) => {
    const jinaUrl = `https://r.jina.ai/${url}`;
    
    console.log(`Testing: ${url}`);
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
        
        console.log(`✅ Response in ${duration}ms (${body.length} chars)`);
        
        // Check for key information
        const checks = {
          'Swiggy Support': body.toLowerCase().includes('swiggy'),
          'Zomato Support': body.toLowerCase().includes('zomato'),
          'India Support': body.toLowerCase().includes('india'),
          'Pricing Info': body.toLowerCase().includes('price') || body.toLowerCase().includes('cost') || body.toLowerCase().includes('free'),
          'API Access': body.toLowerCase().includes('api'),
          'Quote/Contact': body.toLowerCase().includes('quote') || body.toLowerCase().includes('contact'),
        };
        
        console.log('\n📊 Key Information:');
        Object.entries(checks).forEach(([key, found]) => {
          console.log(`  ${key}: ${found ? '✅' : '❌'}`);
        });
        
        // Look for pricing indicators
        const pricingPatterns = [
          /\$\d+/g,
          /£\d+/g,
          /€\d+/g,
          /₹\d+/g,
          /free/gi,
          /trial/gi,
          /subscription/gi,
        ];
        
        const pricingMatches = [];
        pricingPatterns.forEach(pattern => {
          const matches = body.match(pattern);
          if (matches) pricingMatches.push(...matches);
        });
        
        if (pricingMatches.length > 0) {
          console.log('\n💰 Pricing Indicators Found:');
          [...new Set(pricingMatches)].slice(0, 10).forEach(match => {
            console.log(`  - ${match}`);
          });
        }
        
        // Show relevant excerpt
        console.log('\n📄 Content Preview (first 2500 chars):');
        console.log('-'.repeat(80));
        console.log(body.substring(0, 2500));
        console.log('-'.repeat(80));
        
        // Look for platforms supported
        const platforms = ['Swiggy', 'Zomato', 'Deliveroo', 'UberEats', 'JustEat', 'Doordash', 'GrubHub'];
        const foundPlatforms = platforms.filter(p => body.toLowerCase().includes(p.toLowerCase()));
        
        if (foundPlatforms.length > 0) {
          console.log('\n🍔 Platforms Supported:');
          foundPlatforms.forEach(p => console.log(`  ✅ ${p}`));
        }
        
        resolve();
      });
    }).on('error', (error) => {
      console.error(`❌ Error: ${error.message}`);
      resolve();
    });
  });
}

testFoodSparkIO();
