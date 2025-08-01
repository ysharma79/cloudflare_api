import { Router } from 'itty-router';

// Create a new router
const router = Router();

// Mock data for testing when DB is not available
const mockItems = [
  { id: 1, name: 'Test Item 1', description: 'This is a test item', created_at: new Date().toISOString() },
  { id: 2, name: 'Test Item 2', description: 'This is another test item', created_at: new Date().toISOString() }
];

// Define a schema for our data
const ITEMS_TABLE = `CREATE TABLE IF NOT EXISTS items (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, description TEXT, created_at DATETIME DEFAULT CURRENT_TIMESTAMP);`;

// Initialize the database schema
async function initializeDb(db) {
  if (!db) return false;
  return await db.exec(ITEMS_TABLE);
}

// GET items endpoint
router.get('/items', async ({ env }) => {
  try {
    // Check if DB binding exists
    if (!env || !env.DB) {
      console.log('DB binding not available, using mock data');
      // Return mock data instead of an error
      return new Response(JSON.stringify({ 
        success: true, 
        items: mockItems,
        note: 'Using mock data because DB is not available'
      }), {
        headers: { 'Content-Type': 'application/json' },
        status: 200
      });
    }
    
    // Initialize the database if needed
    await initializeDb(env.DB);
    
    // Query all items from the database
    const { results } = await env.DB.prepare('SELECT * FROM items ORDER BY created_at DESC').all();
    
    return new Response(JSON.stringify({ success: true, items: results }), {
      headers: { 'Content-Type': 'application/json' },
      status: 200
    });
  } catch (error) {
    console.error('Error in GET /items:', error);
    return new Response(JSON.stringify({ success: false, error: error.message }), {
      headers: { 'Content-Type': 'application/json' },
      status: 500
    });
  }
});

// GET a single item by ID
router.get('/items/:id', async ({ params, env }) => {
  try {
    // Check if DB binding exists
    if (!env || !env.DB) {
      console.log('DB binding not available, using mock data');
      const { id } = params;
      const item = mockItems.find(item => item.id === parseInt(id));
      
      if (!item) {
        return new Response(JSON.stringify({ success: false, error: 'Item not found' }), {
          headers: { 'Content-Type': 'application/json' },
          status: 404
        });
      }
      
      return new Response(JSON.stringify({ 
        success: true, 
        item,
        note: 'Using mock data because DB is not available'
      }), {
        headers: { 'Content-Type': 'application/json' },
        status: 200
      });
    }
    
    // Initialize the database if needed
    await initializeDb(env.DB);
    
    const { id } = params;
    const { results } = await env.DB.prepare('SELECT * FROM items WHERE id = ?').bind(id).all();
    
    if (results.length === 0) {
      return new Response(JSON.stringify({ success: false, error: 'Item not found' }), {
        headers: { 'Content-Type': 'application/json' },
        status: 404
      });
    }
    
    return new Response(JSON.stringify({ success: true, item: results[0] }), {
      headers: { 'Content-Type': 'application/json' },
      status: 200
    });
  } catch (error) {
    console.error('Error in GET /items/:id:', error);
    return new Response(JSON.stringify({ success: false, error: error.message }), {
      headers: { 'Content-Type': 'application/json' },
      status: 500
    });
  }
});

// POST a new item
router.post('/items', async (request, env) => {
  try {
    // Parse the request body
    const { name, description } = await request.json();
    
    // Validate required fields
    if (!name) {
      return new Response(JSON.stringify({ success: false, error: 'Name is required' }), {
        headers: { 'Content-Type': 'application/json' },
        status: 400
      });
    }

    // Check if DB binding exists
    if (!env || !env.DB) {
      console.log('DB binding not available, using mock data');
      // Create a new mock item
      const newId = mockItems.length > 0 ? Math.max(...mockItems.map(item => item.id)) + 1 : 1;
      const newItem = {
        id: newId,
        name,
        description: description || null,
        created_at: new Date().toISOString()
      };
      
      // Add to mock items
      mockItems.push(newItem);
      
      return new Response(JSON.stringify({ 
        success: true, 
        item: newItem,
        note: 'Using mock data because DB is not available'
      }), {
        headers: { 'Content-Type': 'application/json' },
        status: 201
      });
    }
    
    // Initialize the database if needed
    await initializeDb(env.DB);
    
    // Insert the new item into the database
    const { success, meta } = await env.DB.prepare(
      'INSERT INTO items (name, description) VALUES (?, ?)'
    ).bind(name, description || null).run();
    
    if (!success) {
      throw new Error('Failed to insert item');
    }
    
    // Get the newly created item
    const { results } = await env.DB.prepare('SELECT * FROM items WHERE id = ?').bind(meta.last_row_id).all();
    
    return new Response(JSON.stringify({ success: true, item: results[0] }), {
      headers: { 'Content-Type': 'application/json' },
      status: 201
    });
  } catch (error) {
    console.error('Error in POST /items:', error);
    return new Response(JSON.stringify({ success: false, error: error.message }), {
      headers: { 'Content-Type': 'application/json' },
      status: 500
    });
  }
});

// 404 for everything else
router.all('*', () => new Response('Not Found', { status: 404 }));

// Export a default object containing event handlers
export default {
  // The fetch handler is invoked when this worker receives a HTTP request
  async fetch(request, env, ctx) {
    // Add CORS headers to allow requests from any origin
    const corsHeaders = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    };
    
    // Handle OPTIONS request for CORS preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, {
        headers: corsHeaders,
        status: 204,
      });
    }
    
    try {
      // Process the request with our router
      // Note: We've updated our endpoints to handle missing DB binding
      const response = await router.handle(request, env, ctx);
      
      // Add CORS headers to the response
      Object.keys(corsHeaders).forEach(key => {
        response.headers.set(key, corsHeaders[key]);
      });
      
      return response;
    } catch (error) {
      console.error('Error in fetch handler:', error);
      
      const response = new Response(JSON.stringify({
        success: false,
        error: error.message,
        stack: error.stack
      }), {
        headers: { 'Content-Type': 'application/json' },
        status: 500
      });
      
      // Add CORS headers
      Object.keys(corsHeaders).forEach(key => {
        response.headers.set(key, corsHeaders[key]);
      });
      
      return response;
    }
  }
};
