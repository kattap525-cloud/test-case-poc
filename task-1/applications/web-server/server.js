const express = require('express');
const app = express();
const port = process.env.PORT || 8080;

// Middleware
app.use(express.json());
app.use(express.static('public'));

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'OK', service: 'Web Server', timestamp: new Date().toISOString() });
});

// Home page
app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <title>Microservices Dashboard</title>
    </head>
    <body>
        <div>
            <h1>Microservices Dashboard</h1>
            <p>Welcome to our microservices architecture! Here are the available services:</p>
            
            <div>
                <div>
                    <h3>MSA1 Service</h3>
                    <p>Microservice 1</p>
                    <div>Root: /api/msa1/</div>
                    <div>Health: /api/msa1/actuator/health</div>
                    <a href="/api/msa1/">Access MSA1</a>
                    <a href="/api/msa1/actuator/health">Health Check</a>
                </div>
                <div>
                    <h3>MSA2 Service</h3>
                    <p>Microservice 2</p>
                    <div class="endpoint">Root: /api/msa2/</div>
                    <div class="endpoint">Health: /api/msa2/actuator/health</div>
                    <a href="/api/msa2/">Access MSA2</a>
                    <a href="/api/msa2/actuator/health">Health Check</a>
                </div>
                <div>
                    <h3>MSA3 Service</h3>
                    <p>Microservice 3</p>
                    <div class="endpoint">Root: /api/msa3/</div>
                    <div class="endpoint">Health: /api/msa3/actuator/health</div>
                    <a href="/api/msa3/">Access MSA3</a>
                    <a href="/api/msa3/actuator/health">Health Check</a>
                </div>
            </div>
        </div>
    </body>
    </html>
  `);
});

// Start server
app.listen(port, () => {
  console.log(`Web server running on port ${port}`);
  console.log(`Health check available at /health`);
  console.log(`Home page available at /`);
  console.log(`MSA1 available at /api/msa1/`);
  console.log(`MSA2 available at /api/msa2/`);
  console.log(`MSA3 available at /api/msa3/`);
});
