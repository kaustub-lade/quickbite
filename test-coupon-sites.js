const https = require('https');

async function testCouponSite(siteName, url) {
  return new Promise((resolve, reject) => {
    const jinaUrl = `https://r.jina.ai/${url}`;
    
    console.log(`\n${'='.repeat(80)}`);
    console.log(`🔍 Testing: ${siteName}`);
    console.log(`URL: ${url}`);
    console.log(`Jina URL: ${jinaUrl}`);
    console.log('='.repeat(80));
    
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
        
        console.log(`\n✅ Response received in ${duration}ms`);
        console.log(`Response length: ${body.length} characters`);
        
        // Check if it's an error page
        if (body.includes('Uh-oh') || body.includes('404') || body.includes('Error')) {
          console.log('⚠️ Possible error page detected');
        }
        
        // Look for coupon-related keywords
        const keywords = ['coupon', 'discount', 'off', 'deal', 'save', 'promo', 'code', '%'];
        const foundKeywords = keywords.filter(kw => 
          body.toLowerCase().includes(kw)
        );
        
        console.log(`\n📊 Coupon Keywords Found: ${foundKeywords.length}/${keywords.length}`);
        console.log(`Keywords: ${foundKeywords.join(', ')}`);
        
        // Count potential coupon codes (usually CAPS and numbers)
        const codePattern = /\b[A-Z0-9]{4,15}\b/g;
        const potentialCodes = body.match(codePattern) || [];
        const uniqueCodes = [...new Set(potentialCodes)].slice(0, 20);
        
        console.log(`\n🎫 Potential Coupon Codes Found: ${uniqueCodes.length}`);
        if (uniqueCodes.length > 0) {
          console.log('Sample codes:', uniqueCodes.slice(0, 10).join(', '));
        }
        
        // Look for discount percentages
        const discountPattern = /(\d{1,2})%\s*off/gi;
        const discounts = body.match(discountPattern) || [];
        const uniqueDiscounts = [...new Set(discounts)].slice(0, 10);
        
        console.log(`\n💰 Discount Patterns Found: ${uniqueDiscounts.length}`);
        if (uniqueDiscounts.length > 0) {
          console.log('Examples:', uniqueDiscounts.join(', '));
        }
        
        // Show first 1500 chars
        console.log('\n📄 First 1500 characters of markdown:');
        console.log('-'.repeat(80));
        console.log(body.substring(0, 1500));
        console.log('-'.repeat(80));
        
        // Look for structured coupon data
        const lines = body.split('\n').filter(line => 
          line.toLowerCase().includes('swiggy') || 
          line.toLowerCase().includes('zomato') ||
          line.toLowerCase().includes('food') ||
          line.toLowerCase().includes('amazon') ||
          line.toLowerCase().includes('flipkart')
        ).slice(0, 15);
        
        if (lines.length > 0) {
          console.log('\n🍔 Food/E-commerce Related Lines (first 15):');
          lines.forEach((line, idx) => {
            console.log(`${idx + 1}. ${line.substring(0, 120)}`);
          });
        }
        
        resolve({
          siteName,
          url,
          success: true,
          length: body.length,
          keywords: foundKeywords.length,
          codes: uniqueCodes.length,
          discounts: uniqueDiscounts.length,
          duration
        });
      });
    }).on('error', (error) => {
      console.error(`❌ Error: ${error.message}`);
      resolve({
        siteName,
        url,
        success: false,
        error: error.message
      });
    });
  });
}

async function main() {
  console.log('🎯 Testing Coupon Aggregator Sites with Jina AI');
  console.log('Testing if we can scrape coupon details instead of food platforms\n');
  
  const sites = [
    { name: 'CouponDunia', url: 'https://www.coupondunia.in/' },
    { name: 'GrabOn', url: 'https://www.grabon.in/' },
    { name: 'PaisaWapas', url: 'https://www.paisawapas.com/' }
  ];
  
  const results = [];
  
  for (const site of sites) {
    const result = await testCouponSite(site.name, site.url);
    results.push(result);
    
    // Wait 2 seconds between requests to be polite
    if (sites.indexOf(site) < sites.length - 1) {
      console.log('\n⏳ Waiting 2 seconds before next request...\n');
      await new Promise(resolve => setTimeout(resolve, 2000));
    }
  }
  
  // Summary
  console.log('\n\n' + '='.repeat(80));
  console.log('📊 SUMMARY');
  console.log('='.repeat(80));
  
  results.forEach(result => {
    console.log(`\n${result.siteName}:`);
    console.log(`  Success: ${result.success ? '✅' : '❌'}`);
    if (result.success) {
      console.log(`  Response Size: ${result.length} chars`);
      console.log(`  Coupon Keywords: ${result.keywords}/8`);
      console.log(`  Potential Codes: ${result.codes}`);
      console.log(`  Discounts Found: ${result.discounts}`);
      console.log(`  Scrape Time: ${result.duration}ms`);
      console.log(`  Verdict: ${result.keywords >= 5 && result.codes > 0 ? '✅ Good data!' : '⚠️ Limited data'}`);
    } else {
      console.log(`  Error: ${result.error}`);
    }
  });
  
  console.log('\n' + '='.repeat(80));
  console.log('💡 RECOMMENDATION');
  console.log('='.repeat(80));
  
  const goodSites = results.filter(r => r.success && r.keywords >= 5 && r.codes > 0);
  
  if (goodSites.length > 0) {
    console.log('\n✅ These sites look scrapable:');
    goodSites.forEach(site => console.log(`   - ${site.siteName} (${site.url})`));
    console.log('\n💡 Next steps:');
    console.log('   1. Build coupon scraper for these sites');
    console.log('   2. Store coupons in MongoDB with restaurant mapping');
    console.log('   3. Show coupons in mobile app when ordering');
    console.log('   4. Update coupons daily via cron job');
  } else {
    console.log('\n⚠️ All sites might be blocking or have limited public data');
    console.log('Consider manual coupon entry or official coupon APIs');
  }
  
  console.log('\n');
}

main();
