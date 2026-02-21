# Payment Integration Setup Guide

## Overview
QuickBite now supports online payments through Razorpay integration. This guide explains how to set up and test the payment feature.

## Features
- ✅ Cash on Delivery (COD)
- ✅ Online Payment via Razorpay
- ✅ Payment verification and order tracking
- ✅ Automatic retry on payment failure
- ✅ Secure payment signature verification

## Setup Instructions

### 1. Get Razorpay API Keys

1. Sign up at [Razorpay](https://razorpay.com/)
2. Navigate to **Settings → API Keys**
3. Generate **Test Mode** keys
4. Copy the `Key ID` and `Key Secret`

### 2. Configure Environment Variables

Update `.env.local` file:

```env
RAZORPAY_KEY_ID=rzp_test_your_key_id
RAZORPAY_KEY_SECRET=your_key_secret
RAZORPAY_ENABLED=true
```

**Important:** 
- Never commit `.env.local` to Git (already in `.gitignore`)
- Use test keys for development
- Switch to live keys only in production

### 3. Server Setup

For the backend server to use Razorpay:

1. Install dependencies (already done):
   ```bash
   npm install
   ```

2. Restart the development server:
   ```bash
   npm run dev
   ```

The server will now load Razorpay configuration from environment variables.

## Architecture

### Backend APIs

#### 1. Create Payment Order
**Endpoint:** `POST /api/payment/create-order`

**Request:**
```json
{
  "amount": 299.50,
  "currency": "INR",
  "orderId": "order_id_from_quickbite",
  "receipt": "receipt_order_id"
}
```

**Response:**
```json
{
  "success": true,
  "order": {
    "id": "order_razorpay_id",
    "amount": 29950,
    "currency": "INR",
    "receipt": "receipt_order_id"
  },
  "keyId": "rzp_test_xxxxx"
}
```

#### 2. Verify Payment
**Endpoint:** `POST /api/payment/verify`

**Request:**
```json
{
  "razorpay_order_id": "order_razorpay_id",
  "razorpay_payment_id": "pay_xxxxx",
  "razorpay_signature": "signature_hash",
  "orderId": "quickbite_order_id"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Payment verified successfully",
  "order": {
    "id": "quickbite_order_id",
    "status": "confirmed",
    "paymentStatus": "completed"
  }
}
```

### Database Changes

**Order Model Updates:**

```typescript
{
  paymentStatus: 'pending' | 'processing' | 'completed' | 'failed',
  paymentMethod: 'cod' | 'online',
  paymentDetails: {
    razorpayOrderId?: string,
    razorpayPaymentId?: string,
    razorpaySignature?: string
  },
  paymentFailureReason?: string
}
```

### Mobile App Flow

1. **User selects payment method** (COD or Online)
2. **Place Order button clicked**
3. If Online Payment:
   - Create order in database
   - Call `/api/payment/create-order`
   - Show payment dialog
   - Process payment (mock in demo mode)
   - Call `/api/payment/verify`
   - Navigate to success screen
4. If COD:
   - Create order in database
   - Navigate to success screen

## Testing

### Test Online Payment

1. Run the mobile app:
   ```bash
   cd mobile
   flutter run -d chrome
   ```

2. Add items to cart
3. Go to checkout
4. Select "Online Payment" radio button
5. Fill in delivery address
6. Click "Place Order"
7. Payment dialog appears with:
   - Creating payment order...
   - Processing payment...
   - Verifying payment...
   - Payment successful!

### Test Payment Failure

To test failure scenarios, temporarily modify the payment verification logic in `app/api/payment/verify/route.ts`.

### Test COD

COD flow remains unchanged and works as before.

## Production Deployment

### Switch to Live Mode

1. Generate **Live Mode** keys from Razorpay dashboard
2. Update environment variables on Render:
   ```
   RAZORPAY_KEY_ID=rzp_live_xxxxx
   RAZORPAY_KEY_SECRET=live_key_secret
   RAZORPAY_ENABLED=true
   ```

3. Integrate actual Razorpay SDK in Flutter app:
   ```bash
   flutter pub add razorpay_flutter
   ```

4. Replace mock payment in `_PaymentDialog` with real Razorpay checkout:
   ```dart
   Razorpay razorpay = Razorpay();
   razorpay.open({
     'key': keyId,
     'amount': amount * 100,
     'order_id': orderId,
     'name': 'QuickBite',
     'description': 'Food Order Payment',
     'prefill': {
       'contact': phone,
       'email': email
     }
   });
   ```

### Security Considerations

1. **Never expose Key Secret** in frontend code
2. **Always verify signature** on backend
3. **Use HTTPS** in production
4. **Implement webhook** for payment confirmations
5. **Handle edge cases**:
   - User closes app during payment
   - Network failure mid-payment
   - Duplicate payments

### Webhook Setup (Optional)

To receive automatic payment status updates:

1. Create webhook endpoint:
   ```typescript
   // app/api/payment/webhook/route.ts
   export async function POST(req: NextRequest) {
     const signature = req.headers.get('x-razorpay-signature');
     const body = await req.text();
     
     // Verify webhook signature
     const isValid = verifyWebhookSignature(body, signature);
     
     if (isValid) {
       const event = JSON.parse(body);
       // Handle payment.captured, payment.failed, etc.
     }
   }
   ```

2. Configure webhook URL in Razorpay dashboard:
   ```
   https://quickbite-c016.onrender.com/api/payment/webhook
   ```

## Troubleshooting

### Payment Dialog Doesn't Appear
- Check console for errors
- Verify API endpoints are responding
- Ensure order is created before payment

### Payment Verification Fails
- Check signature generation logic
- Verify Key Secret is correct
- Check order ID matches

### "Payment Gateway Disabled" Error
- Ensure `RAZORPAY_ENABLED=true` in `.env.local`
- Restart development server after changing env vars

## Test Card Details

For testing in Razorpay test mode:

**Credit Card:**
- Card Number: `4111 1111 1111 1111`
- CVV: Any 3 digits
- Expiry: Any future date

**Debit Card:**
- Card Number: `5104 0155 5555 5558`
- CVV: Any 3 digits
- Expiry: Any future date

**UPI:**
- UPI ID: `success@razorpay`

More test cards: https://razorpay.com/docs/payments/payments/test-card-details/

## Files Modified

### Backend
- `lib/razorpay.ts` - Razorpay configuration
- `app/api/payment/create-order/route.ts` - Create payment order
- `app/api/payment/verify/route.ts` - Verify payment
- `lib/models/Order.ts` - Added payment fields

### Mobile
- `mobile/lib/services/api_service.dart` - Payment API methods
- `mobile/lib/screens/checkout_screen.dart` - Payment integration

### Configuration
- `.env.local` - Razorpay credentials

## Support

For Razorpay integration issues, refer to:
- [Razorpay Documentation](https://razorpay.com/docs/)
- [Razorpay Flutter SDK](https://github.com/razorpay/razorpay-flutter)

For QuickBite specific issues, check `ARCHITECTURE.md`.
