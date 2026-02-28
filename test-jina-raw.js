const https = require('https');

async function fetchJinaMarkdown(swiggySlug) {
  return new Promise((resolve, reject) => {
    const url = `https://www.swiggy.com/restaurants/${swiggySlug}-mumbai`;
    const jinaUrl = `https://r.jina.ai/${url}`;
    
    console.log('🔍 Fetching from Jina AI...');
    console.log('URL:', jinaUrl);
    console.log('');
    
    https.get(jinaUrl, {
      headers: {
        'Accept': 'text/plain',
        'X-Return-Format': 'markdown'
      }
    }, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        console.log('✅ Got response from Jina AI');
        console.log('Response length:', body.length, 'characters');
        console.log('');
        console.log('='.repeat(80));
        console.log('FIRST 3000 CHARACTERS OF MARKDOWN:');
        console.log('='.repeat(80));
        console.log(body.substring(0, 3000));
        console.log('='.repeat(80));
        console.log('');
        console.log('='.repeat(80));
        console.log('LAST 2000 CHARACTERS OF MARKDOWN:');
        console.log('='.repeat(80));
        console.log(body.substring(body.length - 2000));
        console.log('='.repeat(80));
        
        // Look for price patterns
        console.log('\n🔍 Looking for price patterns...\n');
        const priceLines = body.split('\n').filter(line => 
          line.includes('₹') || line.includes('Rs') || /\d{2,3}/.test(line)
        ).slice(0, 30);
        
        console.log('Sample lines with prices (first 30):');
        priceLines.forEach((line, idx) => {
          console.log(`${idx + 1}. ${line}`);
        });
        
        resolve(body);
      });
    }).on('error', reject);
  });
}

async function main() {
  try {
    const slug = 'kfc-kurla-west-rest243517';
    const markdown = await fetchJinaMarkdown(slug);
    
    console.log('\n✅ Done! Check the output above to understand the markdown structure.');
    console.log('💡 Use this to update the regex in lib/services/scraper-service.ts -> parseSwiggyMarkdown()');
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

main();
