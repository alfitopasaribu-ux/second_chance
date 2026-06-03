require("dotenv").config();

const { neon } = require("@neondatabase/serverless");
const Groq = require("groq-sdk").default;
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

const sql = neon(process.env.DATABASE_URL);
const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

module.exports = async (req, res) => {
  try {
    req.body = req.body || {};

    if (req.method !== "POST") {
      return res.status(405).json({ success: false, error: "Method tidak didukung" });
    }

    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ success: false, error: "Email dan password wajib diisi" });
    }

    const users = await sql`
      SELECT * FROM users
      WHERE email = ${email}
    `;

    if (users.length === 0) {
      return res.status(400).json({ success: false, error: "User tidak ditemukan" });
    }

    const user = users[0];

    const validPassword = await bcrypt.compare(password, user.password_hash);

    if (!validPassword) {
      return res.status(400).json({ success: false, error: "Password salah" });
    }

    const token = jwt.sign(
      { id: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
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
  } catch (error) {
    console.error(error);
    return res.status(500).json({ success: false, error: error.message });
  }
};

