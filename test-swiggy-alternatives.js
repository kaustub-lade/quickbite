const https = require('https');

// Test alternative food aggregator/API services
async function testAlternatives() {
  const sites = [
    {
      name: 'Swiggy Public Menu API (Unofficial)',
      url: 'https://www.swiggy.com/dapi/menu/pl?page-type=REGULAR_MENU&complete-menu=true&lat=19.0760&lng=72.8777&restaurantId=243517',
      description: 'Swiggy\'s internal API endpoint'
    },
    {
      name: 'Zomato Web API',
      url: 'https://www.zomato.com/webroutes/getPage',
      description: 'Zomato\'s public web API'
    },
    {
      name: 'Petpooja (Restaurant Management)',
      url: 'https://www.petpooja.com/',
      description: 'Restaurant POS that syncs with Swiggy/Zomato'
    }
  ];
  
  console.log('🔍 Testing Alternative Solutions for Swiggy Menu Data\n');
  console.log('Since FoodSparks doesn\'t exist, testing other approaches...\n');
  console.log('='.repeat(80) + '\n');
  
  for (const site of sites) {
    await testSite(site);
    console.log('\n' + '='.repeat(80) + '\n');
    await new Promise(resolve => setTimeout(resolve, 2000));
  }
}

async function testSite(site) {
  return new Promise((resolve) => {
    console.log(`📍 ${site.name}`);
    console.log(`Description: ${site.description}`);
    console.log(`URL: ${site.url}`);
    
    const jinaUrl = `https://r.jina.ai/${site.url}`;
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
        
        console.log(`\n✅ Response in ${duration}ms`);
        console.log(`Length: ${body.length} characters`);
        
        // Check if it's JSON (API response)
        let isJson = false;
        try {
          JSON.parse(body);
          isJson = true;
          console.log('📦 Format: JSON (API endpoint!)');
        } catch {
          console.log('📄 Format: HTML/Markdown');
        }
        
        // Look for menu data indicators
        const hasMenuData = body.includes('menu') || body.includes('item') || body.includes('dish');
        const hasPricing = body.includes('price') || body.includes('₹') || body.includes('rupee');
        const hasRestaurant = body.includes('restaurant') || body.includes('Swiggy') || body.includes('Zomato');
        
        console.log('\n📊 Data Quality:');
        console.log(`  Menu Data: ${hasMenuData ? '✅' : '❌'}`);
        console.log(`  Pricing: ${hasPricing ? '✅' : '❌'}`);
        console.log(`  Restaurant Info: ${hasRestaurant ? '✅' : '❌'}`);
        
        if (hasMenuData && hasPricing) {
          console.log('\n🎉 This looks promising!');
        }
        
        // Show sample
        console.log('\n📄 Sample (first 1500 chars):');
        console.log('-'.repeat(80));
        console.log(body.substring(0, 1500));
        console.log('-'.repeat(80));
        
        resolve();
      });
    }).on('error', (error) => {
      console.error(`❌ Error: ${error.message}`);
      resolve();
    });
  });
}

testAlternatives();
