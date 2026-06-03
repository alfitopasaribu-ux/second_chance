require("dotenv").config();

const { neon } = require("@neondatabase/serverless");

const sql = neon(process.env.DATABASE_URL);

// Endpoint minimal agar frontend tidak 404.
// Kalau kamu punya logic analysis asli di TS/Express, nanti bisa kita port.
module.exports = async (req, res) => {
  try {
    req.body = req.body || {};

    if (req.method !== "POST") {
      return res.status(405).json({ success: false, error: "Method tidak didukung" });
    }

    // placeholder: kembalikan dummy scores
    // nanti bisa diganti dengan logic yang sesuai app kamu
    return res.status(200).json({
      success: true,
      empathetic_score: 0,
      honesty_score: 0,
      confidence_score: 0,
      tension_score: 0,
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ success: false, error: error.message });
  }
};

