const mongoose = require('mongoose');
require('dotenv').config({ path: '.env.local' });

// Import the Firecrawl client directly
const FirecrawlApp = require('@mendable/firecrawl-js').default;

async function testFirecrawlDirectly() {
  try {
    console.log('🔥 Testing Firecrawl with stealth mode...\n');
    
    const app = new FirecrawlApp({ apiKey: process.env.FIRECRAWL_API_KEY });
    const url = 'https://www.swiggy.com/restaurants/kfc-kurla-west-rest243517-mumbai';
    
    console.log('URL:', url);
    console.log('Starting scrape with Firecrawl...\n');
    
    const startTime = Date.now();
    const result = await app.scrape(url, {
      formats: ['markdown'],
      onlyMainContent: true,
      waitFor: 3000  // Wait for JS to load
    });
    
    const duration = Date.now() - startTime;
    
    console.log('✅ Scrape complete in', duration, 'ms');
    console.log('Markdown length:', result.markdown?.length || 0, 'characters\n');
    
    if (result.markdown) {
      console.log('='.repeat(80));
      console.log('FIRST 2000 CHARACTERS:');
      console.log('='.repeat(80));
      console.log(result.markdown.substring(0, 2000));
      console.log('='.repeat(80));
      
      // Look for prices
      const priceLines = result.markdown.split('\n').filter(line => 
        line.includes('₹') || line.includes('Rs') || /\d{2,3}/.test(line)
      ).slice(0, 30);
      
      if (priceLines.length > 0) {
        console.log('\n🔍 Lines with potential prices (first 30):');
        priceLines.forEach((line, idx) => {
          console.log(`${idx + 1}. ${line.substring(0, 150)}`);
        });
      } else {
        console.log('\n⚠️ No price patterns found');
      }
    } else {
      console.log('❌ No markdown returned');
    }
    
  } catch (error) {
    console.error('❌ Firecrawl error:', error.message);
    if (error.response) {
      console.error('Response:', error.response.data);
    }
  }
}

testFirecrawlDirectly();
