require("dotenv").config();

const { neon } = require("@neondatabase/serverless");
const Groq = require("groq-sdk").default;
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

const sql = neon(process.env.DATABASE_URL);

const groq = new Groq({
  apiKey: process.env.GROQ_API_KEY,
});

module.exports = async (req, res) => {
  try {

    req.body = req.body || {};

    // ROOT CHECK
    if (req.method === "GET" && req.url === "/") {

      const result = await sql`SELECT NOW()`;

      return res.status(200).json({
        status: "ONLINE",
        project: "SECOND CHANCE",
        database: "CONNECTED",
        ai: "ACTIVE",
        time: result[0],
      });
    }

    // REGISTER
    if (
      req.method === "POST" &&
      req.url.includes("register")
    ) {

      const { username, email, password } = req.body;

      if (!username || !email || !password) {
        return res.status(400).json({
          success: false,
          error: "Semua field wajib diisi",
        });
      }

      const existingUser = await sql`
        SELECT * FROM users
        WHERE email = ${email}
      `;

      if (existingUser.length > 0) {
        return res.status(400).json({
          success: false,
          error: "Email sudah digunakan",
        });
      }

      const hashedPassword =
        await bcrypt.hash(password, 10);

      const newUser = await sql`
        INSERT INTO users (
          username,
          email,
          password_hash
        )
        VALUES (
          ${username},
          ${email},
          ${hashedPassword}
        )
        RETURNING id, username, email
      `;

      return res.status(201).json({
        success: true,
        message: "Register berhasil",
        user: newUser[0],
      });
    }

    // LOGIN
    if (
      req.method === "POST" &&
      req.url.includes("login")
    ) {

      const { email, password } = req.body;

      if (!email || !password) {
        return res.status(400).json({
          success: false,
          error: "Email dan password wajib diisi",
        });
      }

      const users = await sql`
        SELECT * FROM users
        WHERE email = ${email}
      `;

      if (users.length === 0) {
        return res.status(400).json({
          success: false,
          error: "User tidak ditemukan",
        });
      }

      const user = users[0];

      const validPassword =
        await bcrypt.compare(
          password,
          user.password_hash
        );

      if (!validPassword) {
        return res.status(400).json({
          success: false,
          error: "Password salah",
        });
      }

      const token = jwt.sign(
        {
          id: user.id,
          email: user.email,
        },
        process.env.JWT_SECRET,
        {
          expiresIn: "7d",
        }
      );

      return res.status(200).json({
        success: true,
        message: "Login berhasil",
        token,
        user: {
          id: user.id,
          username: user.username,
          email: user.email,
        },
      });
    }

    // AI CHAT
    if (
      req.method === "POST" &&
      req.url.includes("chat")
    ) {

      const { message } = req.body;

      if (!message) {
        return res.status(400).json({
          success: false,
          error: "Message wajib diisi",
        });
      }

      const completion =
        await groq.chat.completions.create({
          messages: [
            {
              role: "system",
              content:
                "Kamu adalah AI emosional realistis untuk aplikasi SECOND CHANCE.",
            },
            {
              role: "user",
              content: message,
            },
          ],
          model: "llama3-70b-8192",
        });

      return res.status(200).json({
        success: true,
        reply:
          completion.choices[0].message.content,
      });
    }

    return res.status(404).json({
      success: false,
      error: "Route tidak ditemukan",
    });

  } catch (error) {

    console.error(error);

    return res.status(500).json({
      success: false,
      error: error.message,
    });

  }
};