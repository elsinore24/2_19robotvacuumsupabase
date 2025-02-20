import { serve } from 'https://deno.fresh.runtime.dev/server'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0'
import { sign } from 'https://deno.land/x/aws4fetch@v1.0.2/mod.ts'

const REGION = 'us-west-2'
const SERVICE = 'ProductAdvertisingAPI'
const HOST = `webservices.amazon.com`
const PATH = '/paapi5/searchitems'

// Validate required environment variables
const requiredEnvVars = ['AMAZON_ACCESS_KEY', 'AMAZON_SECRET_KEY', 'AMAZON_PARTNER_TAG']
for (const envVar of requiredEnvVars) {
  if (!Deno.env.get(envVar)) {
    throw new Error(`Missing required environment variable: ${envVar}`)
  }
}

interface SearchParams {
  keywords?: string
  brand?: string
  minPrice?: number
  maxPrice?: number
  sortBy?: string
}

serve(async (req) => {
  try {
    // Verify request is from our application
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response('Unauthorized', { status: 401 })
    }

    // Get search parameters
    const url = new URL(req.url)
    const searchParams: SearchParams = {
      keywords: url.searchParams.get('keywords') || 'robot vacuum',
      brand: url.searchParams.get('brand') || undefined,
      minPrice: url.searchParams.get('minPrice') ? Number(url.searchParams.get('minPrice')) : undefined,
      maxPrice: url.searchParams.get('maxPrice') ? Number(url.searchParams.get('maxPrice')) : undefined,
      sortBy: url.searchParams.get('sortBy') || 'Featured'
    }

    // Construct PA API request
    const payload = {
      'Keywords': searchParams.keywords,
      'Resources': [
        'ItemInfo.Title',
        'ItemInfo.Features',
        'ItemInfo.TechnicalInfo',
        'Images.Primary.Large',
        'Offers.Listings.Price',
        'CustomerReviews.Count',
        'CustomerReviews.StarRating'
      ],
      'PartnerTag': Deno.env.get('AMAZON_PARTNER_TAG'),
      'PartnerType': 'Associates',
      'Marketplace': 'www.amazon.com',
      'Operation': 'SearchItems'
    }

    if (searchParams.brand) {
      payload['Brand'] = searchParams.brand
    }

    const request = new Request(`https://${HOST}${PATH}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Amz-Target': 'com.amazon.paapi5.v1.ProductAdvertisingAPIv1.SearchItems'
      },
      body: JSON.stringify(payload)
    })

    // Sign the request with AWS credentials
    const signedRequest = await sign(request, {
      accessKeyId: Deno.env.get('AMAZON_ACCESS_KEY') || '',
      secretAccessKey: Deno.env.get('AMAZON_SECRET_KEY') || '',
      region: REGION,
      service: SERVICE
    })

    // Make the request to Amazon PA API
    const response = await fetch(signedRequest)
    const data = await response.json()

    // Process and return the results
    return new Response(JSON.stringify(data), {
      headers: { 'Content-Type': 'application/json' }
    })

  } catch (error) {
    console.error('Error:', error)
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    })
  }
})