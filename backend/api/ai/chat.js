require("dotenv").config();

const Groq = require("groq-sdk").default;

const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

module.exports = async (req, res) => {
  try {
    req.body = req.body || {};

    if (req.method !== "POST") {
      return res.status(405).json({ success: false, error: "Method tidak didukung" });
    }

    const { message } = req.body;

    if (!message) {
      return res.status(400).json({ success: false, error: "Message wajib diisi" });
    }

    const completion = await groq.chat.completions.create({
      messages: [
        {
          role: "system",
          content: "Kamu adalah AI emosional realistis untuk aplikasi SECOND CHANCE.",
        },
        { role: "user", content: message },
      ],
      model: "llama3-70b-8192",
    });

    return res.status(200).json({
      success: true,
      reply: completion.choices[0].message.content,
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ success: false, error: error.message });
  }
};

