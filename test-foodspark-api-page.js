const https = require('https');

async function testFoodDataAPI() {
  const url = 'https://www.foodspark.io/food-data-api/';
  const jinaUrl = `https://r.jina.ai/${url}`;
  
  console.log('🔍 Testing FoodSpark.io Food Data API Page\n');
  console.log(`URL: ${url}\n`);
  console.log('='.repeat(80) + '\n');
  
  return new Promise((resolve) => {
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
        
        console.log(`✅ Response in ${duration}ms (${body.length} chars)\n`);
        
        // Look for API-related info
        const hasAPIKey = body.toLowerCase().includes('api key') || body.toLowerCase().includes('apikey');
        const hasAuthentication = body.toLowerCase().includes('authentication') || body.toLowerCase().includes('token');
        const hasPricing = body.toLowerCase().includes('price') || body.toLowerCase().includes('cost') || body.toLowerCase().includes('$');
        const hasDocumentation = body.toLowerCase().includes('documentation') || body.toLowerCase().includes('docs');
        const hasFree = body.toLowerCase().includes('free trial') || body.toLowerCase().includes('free tier');
        const hasSwiggy = body.toLowerCase().includes('swiggy');
        const hasZomato = body.toLowerCase().includes('zomato');
        
        console.log('📊 API Information Found:');
        console.log(`  API Key Mentioned: ${hasAPIKey ? '✅' : '❌'}`);
        console.log(`  Authentication: ${hasAuthentication ? '✅' : '❌'}`);
        console.log(`  Pricing Info: ${hasPricing ? '✅' : '❌'}`);
        console.log(`  Documentation: ${hasDocumentation ? '✅' : '❌'}`);
        console.log(`  Free Trial/Tier: ${hasFree ? '✅' : '❌'}`);
        console.log(`  Swiggy Support: ${hasSwiggy ? '✅' : '❌'}`);
        console.log(`  Zomato Support: ${hasZomato ? '✅' : '❌'}`);
        
        console.log('\n📄 Full Content:\n');
        console.log('='.repeat(80));
        console.log(body);
        console.log('='.repeat(80));
        
        // Extract contact/quote info
        const emailPattern = /[\w.-]+@[\w.-]+\.\w+/g;
        const emails = body.match(emailPattern);
        
        if (emails) {
          console.log('\n📧 Contact Emails Found:');
          [...new Set(emails)].forEach(email => console.log(`  ${email}`));
        }
        
        console.log('\n💡 SUMMARY:');
        console.log('FoodSpark.io is a B2B data scraping service (not a self-service API)');
        console.log('You need to "Request a Quote" to get custom pricing');
        console.log('They scrape Swiggy/Zomato/etc. and deliver data to you');
        console.log('This is NOT a free API you can integrate directly');
        
        resolve();
      });
    }).on('error', (error) => {
      console.error(`❌ Error: ${error.message}`);
      resolve();
    });
  });
}

testFoodDataAPI();
