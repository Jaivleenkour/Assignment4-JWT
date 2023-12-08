const express = require('express');
const passport = require('passport');
const BearerStrategy = require('passport-http-bearer').Strategy;
const JwtStrategy = require('passport-jwt').Strategy;
const ExtractJwt = require('passport-jwt').ExtractJwt;
const { MongoClient, ServerApiVersion } = require('mongodb');
const jwt = require('jsonwebtoken');

const app = express();
const port = 3000;

const uri = "mongodb+srv://zany:zayno@cluster0.h9pi4ss.mongodb.net/?retryWrites=true&w=majority";
const client = new MongoClient(uri, {
  serverApi: {
    version: ServerApiVersion.v1,
    strict: true,
    deprecationErrors: true,
  }
});

const users = [
  { id: 1, token: 'test_token', name: 'DemoUser' }
  // Add more users as needed
];

// Configure Passport with Bearer Strategy
passport.use(new BearerStrategy((token, done) => {
  const user = users.find(u => u.token === token);
  if (!user) {
    return done(null, false);
  }
  return done(null, user);
}));

// Configure Passport with JWT Strategy
const jwtOptions = {
  jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
  secretOrKey: 'your_secret_key',
};

passport.use(new JwtStrategy(jwtOptions, (payload, done) => {
  // Check if the user exists in your system based on the payload data
  // For example, you can check the user ID in your database
  const user = users.find(u => u.id === payload.sub);

  if (user) {
    return done(null, user);
  } else {
    return done(null, false);
  }
}));

async function run() {
  try {
    await client.connect();
    await client.db("admin").command({ ping: 1 });
    console.log("Pinged your deployment. You successfully connected to MongoDB!");
  } catch (error) {
    console.error("Error connecting to MongoDB:", error);
  }
}

// Fetch books route
app.get('/books', async (req, res) => {
  try {
    await client.connect();
    const database = client.db("test"); // Replace with your actual database name
    const collection = database.collection("books");

    const books = await collection.find().toArray();
    res.json(books);
  } catch (error) {
    console.error("Error fetching books:", error);
    res.status(500).json({ error: "Internal Server Error" });
  } finally {
    await client.close();
  }
});

// Protected route that requires a valid Bearer token
app.get('/protected-bearer', passport.authenticate('bearer', { session: false }), (req, res) => {
  res.json({ message: 'Authenticated successfully with Bearer token!' });
});

// Protected route that requires a valid JWT token
app.get('/protected-jwt', passport.authenticate('jwt', { session: false }), (req, res) => {
  res.json({ message: 'Authenticated successfully with JWT token!' });
});

// Endpoint to generate a JWT token (example: after successful login)
app.post('/generate-token', (req, res) => {
  const userID = req.body.userID; // Replace with the actual user ID
  const token = generateJWTToken(userID);
  res.json({ token });
});

// Example function to generate a JWT token
function generateJWTToken(userID) {
  return jwt.sign({ sub: userID }, 'your_secret_key', { expiresIn: '1h' });
}

app.listen(port, () => {
  run().catch(console.dir);
  console.log(`Server is running on http://localhost:${port}`);
});
