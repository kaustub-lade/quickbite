// Razorpay configuration
// For production, these should be in environment variables
export const razorpayConfig = {
  keyId: process.env.RAZORPAY_KEY_ID || 'rzp_test_SAMPLE_KEY_ID',
  keySecret: process.env.RAZORPAY_KEY_SECRET || 'SAMPLE_KEY_SECRET',
  enabled: process.env.RAZORPAY_ENABLED === 'true' || false,
};

// Test mode credentials (will be replaced with real ones in production)
// Sign up at https://razorpay.com/ to get test credentials
export const isPaymentEnabled = razorpayConfig.enabled;
