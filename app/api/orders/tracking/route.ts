import { NextRequest } from 'next/server';
import connectDB from '@/lib/mongodb';
import { OrderTracking } from '@/lib/models/OrderTracking';
import { authenticateUser } from '@/lib/middleware/auth';

// GET - Track order in real-time (Server-Sent Events)
export async function GET(req: NextRequest) {
  const { searchParams } = new URL(req.url);
  const orderId = searchParams.get('orderId');
  const stream = searchParams.get('stream') === 'true';

  if (!orderId) {
    return Response.json({ error: 'orderId is required' }, { status: 400 });
  }

  try {
    const { user, error } = await authenticateUser(req);
    if (error || !user) {
      return Response.json({ error: error || 'Unauthorized' }, { status: 401 });
    }

    await connectDB();

    // If streaming is requested, use Server-Sent Events
    if (stream) {
      const encoder = new TextEncoder();
      
      const stream = new ReadableStream({
        async start(controller) {
          // Send initial tracking data
          const tracking = await OrderTracking.findOne({ orderId, userId: user.id });
          
          if (!tracking) {
            controller.enqueue(encoder.encode(`data: ${JSON.stringify({ error: 'Order not found' })}\n\n`));
            controller.close();
            return;
          }

          // Send initial data
          controller.enqueue(encoder.encode(`data: ${JSON.stringify({ 
            type: 'initial',
            tracking 
          })}\n\n`));

          // Poll for updates every 5 seconds
          const intervalId = setInterval(async () => {
            try {
              const updatedTracking = await OrderTracking.findOne({ orderId, userId: user.id });
              
              if (updatedTracking) {
                controller.enqueue(encoder.encode(`data: ${JSON.stringify({ 
                  type: 'update',
                  tracking: updatedTracking 
                })}\n\n`));

                // Close stream if order is delivered or cancelled
                if (updatedTracking.status === 'delivered' || updatedTracking.status === 'cancelled') {
                  clearInterval(intervalId);
                  controller.close();
                }
              }
            } catch (err) {
              console.error('SSE polling error:', err);
            }
          }, 5000);

          // Clean up on client disconnect
          req.signal.addEventListener('abort', () => {
            clearInterval(intervalId);
            controller.close();
          });
        }
      });

      return new Response(stream, {
        headers: {
          'Content-Type': 'text/event-stream',
          'Cache-Control': 'no-cache',
          'Connection': 'keep-alive',
        },
      });
    }

    // Regular HTTP response (not streaming)
    const tracking = await OrderTracking.findOne({ orderId, userId: user.id });

    if (!tracking) {
      return Response.json({ error: 'Order tracking not found' }, { status: 404 });
    }

    // Calculate ETA if out for delivery
    let etaMinutes = null;
    if (tracking.status === 'out_for_delivery' && tracking.estimatedDeliveryTime) {
      const now = new Date();
      const eta = tracking.estimatedDeliveryTime;
      etaMinutes = Math.max(0, Math.round((eta.getTime() - now.getTime()) / 60000));
    }

    return Response.json({
      success: true,
      tracking: {
        orderId: tracking.orderId,
        status: tracking.status,
        statusHistory: tracking.statusHistory,
        deliveryPerson: tracking.deliveryPerson,
        estimatedDeliveryTime: tracking.estimatedDeliveryTime,
        actualDeliveryTime: tracking.actualDeliveryTime,
        etaMinutes
      }
    });
  } catch (error: any) {
    console.error('Order tracking error:', error);
    return Response.json(
      { error: 'Failed to fetch order tracking', details: error.message },
      { status: 500 }
    );
  }
}

// POST - Create order tracking (called when order is placed)
export async function POST(req: NextRequest) {
  try {
    const { user, error } = await authenticateUser(req);
    if (error || !user) {
      return Response.json({ error: error || 'Unauthorized' }, { status: 401 });
    }

    await connectDB();

    const body = await req.json();
    const { orderId, restaurantId } = body;

    if (!orderId || !restaurantId) {
      return Response.json(
        { error: 'Missing required fields: orderId, restaurantId' },
        { status: 400 }
      );
    }

    // Check if tracking already exists
    const existing = await OrderTracking.findOne({ orderId });
    if (existing) {
      return Response.json({ error: 'Tracking already exists for this order' }, { status: 409 });
    }

    // Create tracking with estimated delivery time (40 mins from now)
    const estimatedDeliveryTime = new Date();
    estimatedDeliveryTime.setMinutes(estimatedDeliveryTime.getMinutes() + 40);

    const tracking = await OrderTracking.create({
      orderId,
      userId: user.id,
      restaurantId,
      status: 'pending',
      statusHistory: [{
        status: 'pending',
        timestamp: new Date(),
        note: 'Order placed successfully'
      }],
      estimatedDeliveryTime
    });

    return Response.json({
      success: true,
      message: 'Order tracking created',
      tracking
    }, { status: 201 });
  } catch (error: any) {
    console.error('Create tracking error:', error);
    return Response.json(
      { error: 'Failed to create order tracking', details: error.message },
      { status: 500 }
    );
  }
}

// PATCH - Update order location/status (for delivery person)
export async function PATCH(req: NextRequest) {
  try {
    const { user, error } = await authenticateUser(req);
    if (error || !user) {
      return Response.json({ error: error || 'Unauthorized' }, { status: 401 });
    }

    await connectDB();

    const body = await req.json();
    const { orderId, location, deliveryPerson } = body;

    if (!orderId) {
      return Response.json({ error: 'orderId is required' }, { status: 400 });
    }

    const tracking = await OrderTracking.findOne({ orderId });

    if (!tracking) {
      return Response.json({ error: 'Order tracking not found' }, { status: 404 });
    }

    // Update delivery person location
    if (location && location.latitude && location.longitude) {
      tracking.deliveryPerson = tracking.deliveryPerson || {};
      tracking.deliveryPerson.currentLocation = {
        latitude: location.latitude,
        longitude: location.longitude,
        lastUpdated: new Date()
      };

      tracking.statusHistory.push({
        status: tracking.status,
        timestamp: new Date(),
        note: 'Location updated',
        location: {
          latitude: location.latitude,
          longitude: location.longitude
        }
      });
    }

    // Update delivery person details
    if (deliveryPerson) {
      tracking.deliveryPerson = {
        ...tracking.deliveryPerson,
        ...deliveryPerson
      };
    }

    await tracking.save();

    return Response.json({
      success: true,
      message: 'Tracking updated',
      tracking
    });
  } catch (error: any) {
    console.error('Update tracking error:', error);
    return Response.json(
      { error: 'Failed to update tracking', details: error.message },
      { status: 500 }
    );
  }
}
