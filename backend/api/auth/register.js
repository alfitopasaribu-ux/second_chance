require("dotenv").config();

const { neon } = require("@neondatabase/serverless");
const bcrypt = require("bcryptjs");

const sql = neon(process.env.DATABASE_URL);

module.exports = async (req, res) => {
  try {
    req.body = req.body || {};

    if (req.method !== "POST") {
      return res.status(405).json({ success: false, error: "Method tidak didukung" });
    }

    const { username, email, password } = req.body;

    if (!username || !email || !password) {
      return res.status(400).json({ success: false, error: "Semua field wajib diisi" });
    }

    const existingUser = await sql`
      SELECT * FROM users
      WHERE email = ${email}
    `;

    if (existingUser.length > 0) {
      return res.status(400).json({ success: false, error: "Email sudah digunakan" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

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
  } catch (error) {
    console.error(error);
    return res.status(500).json({ success: false, error: error.message });
  }
};

