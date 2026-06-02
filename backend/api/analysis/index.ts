import { IncomingMessage, ServerResponse } from 'http';
import Groq from 'groq-sdk';
import { query } from '../../lib/neon';
import { getAuthUser, setCorsHeaders, sendJson, parseBody } from '../../lib/auth';

const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

export default async function handler(req: IncomingMessage, res: ServerResponse) {
  setCorsHeaders(res);
  if (req.method === 'OPTIONS') return sendJson(res, 200, {});

  if (req.method !== 'POST') return sendJson(res, 405, { error: 'Method tidak diizinkan' });

  const user = getAuthUser(req);
  if (!user) return sendJson(res, 401, { error: 'Token tidak valid' });

  try {
    const { conversation_id } = await parseBody(req);
    if (!conversation_id) return sendJson(res, 400, { error: 'conversation_id wajib diisi' });

    // Ambil semua pesan user dari percakapan ini
    const messages = await query(
      `SELECT sender, message FROM messages 
       WHERE conversation_id = $1 ORDER BY created_at ASC`,
      [conversation_id]
    );

    if (!messages.length) {
      return sendJson(res, 400, { error: 'Tidak ada pesan untuk dianalisis' });
    }

    const userMessages = messages.filter((m: any) => m.sender === 'user').map((m: any) => m.message);
    const conversationText = messages.map((m: any) => `${m.sender === 'user' ? 'Pengguna' : 'AI'}: ${m.message}`).join('\n');

    const analysisPrompt = `Kamu adalah analis emosi dan komunikasi ahli. Analisis percakapan berikut dan berikan skor dalam format JSON.

PERCAKAPAN:
${conversationText}

Berikan analisis HANYA dalam format JSON berikut (tanpa teks lain):
{
  "empathy_score": <0-100>,
  "honesty_score": <0-100>,
  "confidence_score": <0-100>,
  "tension_score": <0-100>,
  "overall_score": <0-100>,
  "feedback_text": "<umpan balik konstruktif dalam Bahasa Indonesia, 2-3 kalimat>",
  "strengths": ["<kekuatan 1>", "<kekuatan 2>"],
  "improvements": ["<hal yang perlu ditingkatkan 1>", "<hal yang perlu ditingkatkan 2>"]
}

Penjelasan skor:
- empathy_score: Seberapa empatik pengguna dalam berkomunikasi
- honesty_score: Seberapa jujur dan autentik ekspresi pengguna
- confidence_score: Seberapa percaya diri pengguna dalam menyampaikan pesan
- tension_score: Seberapa tinggi ketegangan dalam percakapan (rendah = lebih baik untuk komunikasi)
- overall_score: Skor keseluruhan kemampuan komunikasi emosional`;

    const completion = await groq.chat.completions.create({
      model: 'llama-3.3-70b-versatile',
      messages: [{ role: 'user', content: analysisPrompt }],
      temperature: 0.3,
      max_tokens: 500,
    });

    const responseText = completion.choices[0]?.message?.content || '{}';
    
    let analysis;
    try {
      const jsonMatch = responseText.match(/\{[\s\S]*\}/);
      analysis = jsonMatch ? JSON.parse(jsonMatch[0]) : {};
    } catch {
      analysis = {
        empathy_score: 65, honesty_score: 70, confidence_score: 60,
        tension_score: 40, overall_score: 65,
        feedback_text: 'Percakapan menunjukkan upaya komunikasi yang baik. Terus berlatih untuk meningkatkan kemampuan emosional kamu.',
        strengths: ['Berani memulai percakapan', 'Menunjukkan keberanian'],
        improvements: ['Tingkatkan empati', 'Lebih percaya diri dalam ekspresi']
      };
    }

    // Cek apakah sudah ada feedback untuk conversation ini
    const existing = await query(
      'SELECT id FROM ai_feedback WHERE conversation_id = $1 LIMIT 1',
      [conversation_id]
    );

    let feedback;
    if (existing.length > 0) {
      const result = await query(
        `UPDATE ai_feedback SET 
          empathy_score = $1, honesty_score = $2, confidence_score = $3,
          tension_score = $4, overall_score = $5, feedback_text = $6,
          strengths = $7, improvements = $8
         WHERE conversation_id = $9 RETURNING *`,
        [
          analysis.empathy_score || 0, analysis.honesty_score || 0,
          analysis.confidence_score || 0, analysis.tension_score || 0,
          analysis.overall_score || 0, analysis.feedback_text || '',
          analysis.strengths || [], analysis.improvements || [],
          conversation_id
        ]
      );
      feedback = result[0];
    } else {
      const result = await query(
        `INSERT INTO ai_feedback 
          (conversation_id, user_id, empathy_score, honesty_score, confidence_score, tension_score, overall_score, feedback_text, strengths, improvements)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) RETURNING *`,
        [
          conversation_id, user.userId,
          analysis.empathy_score || 0, analysis.honesty_score || 0,
          analysis.confidence_score || 0, analysis.tension_score || 0,
          analysis.overall_score || 0, analysis.feedback_text || '',
          analysis.strengths || [], analysis.improvements || []
        ]
      );
      feedback = result[0];
    }

    // Mark conversation as completed
    await query(
      'UPDATE conversations SET is_completed = true WHERE id = $1',
      [conversation_id]
    );

    return sendJson(res, 200, { success: true, data: feedback });
  } catch (error: any) {
    console.error('Analysis error:', error);
    return sendJson(res, 500, { error: 'Gagal menganalisis percakapan', detail: error.message });
  }
}
