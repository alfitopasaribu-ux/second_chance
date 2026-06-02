require("dotenv").config();

const { neon } = require("@neondatabase/serverless");
const Groq = require("groq-sdk").default;

const sql = neon(process.env.DATABASE_URL);

const groq = new Groq({
  apiKey: process.env.GROQ_API_KEY,
});

module.exports = async (req, res) => {
  try {
    // ROOT CHECK
    if (req.method === "GET") {
      const result = await sql`SELECT NOW()`;

      return res.status(200).json({
        status: "ONLINE",
        project: "SECOND CHANCE",
        database: "CONNECTED",
        ai: "ACTIVE",
        time: result[0],
      });
    }

    // AI CHAT
    if (req.method === "POST") {
      const { message } = req.body;

      const completion = await groq.chat.completions.create({
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
        reply: completion.choices[0].message.content,
      });
    }

    return res.status(405).json({
      error: "Method not allowed",
    });
  } catch (error) {
    return res.status(500).json({
      error: error.message,
    });
  }
};