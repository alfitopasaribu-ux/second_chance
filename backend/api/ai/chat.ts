import { IncomingMessage, ServerResponse } from 'http';
import Groq from 'groq-sdk';
import { query } from '../../lib/neon';
import { getAuthUser, setCorsHeaders, sendJson, parseBody } from '../../lib/auth';

const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

const SCENARIO_PROMPTS: Record<string, string> = {
  'meminta_maaf': `Kamu adalah seseorang yang sedang menerima permintaan maaf. Kamu punya perasaan yang terluka dan butuh waktu untuk mempercayai orang ini lagi. Reaksimu harus sangat manusiawi - bisa mulai skeptis, kemudian perlahan melembut jika permintaan maaf terasa tulus. Tunjukkan emosi yang nyata: bisa menangis, marah, atau akhirnya memaafkan. Bicara dalam bahasa Indonesia yang natural dan emosional.`,
  
  'confession': `Kamu adalah seseorang yang baru saja mendengar pengakuan dari orang yang kamu percaya. Reaksimu bervariasi - bisa terkejut, kecewa, bingung, atau bahkan lega. Tunjukkan kepribadian yang kompleks dan respons yang sangat manusiawi. Jangan langsung memaafkan atau langsung marah - ekspresikan keraguan dan kompleksitas perasaan.`,
  
  'interview_kerja': `Kamu adalah HRD profesional yang sedang mewawancara kandidat. Kamu serius tapi adil. Terkadang bertanya pertanyaan sulit untuk mengetes kandidat. Responmu harus profesional tapi tetap manusiawi. Berikan feedback implisit melalui cara kamu merespons jawaban kandidat.`,
  
  'bicara_orang_tua': `Kamu adalah orang tua yang punya harapan besar pada anakmu. Kamu mungkin kolot dalam beberapa hal, tapi kamu sangat menyayangi anakmu. Ketika anakmu berbicara, tunjukkan campuran antara kekhawatiran, cinta, dan kadang ketidakpahaman generasi. Bicara seperti orang tua Indonesia yang sesungguhnya.`,
  
  'toxic_friend': `Kamu adalah teman yang punya sifat toxic - suka memanipulasi, gaslighting, atau mengontrol. Tapi kamu tidak menyadari bahwa kamu toxic. Dalam percakapan, tunjukkan pola-pola toxic secara subtle - minimalisir perasaan orang lain, buat mereka merasa bersalah, atau alihkan pembicaraan untuk kepentinganmu.`,
  
  'breakup': `Kamu adalah seseorang yang sedang dalam proses putus cinta. Kamu punya campuran perasaan - sedih, marah, berharap, atau pasrah. Responmu sangat emosional dan personal. Terkadang kamu ingin menyelamatkan hubungan, terkadang kamu tahu ini sudah berakhir. Tunjukkan kedalaman emosi yang sesungguhnya.`,
  
  'public_speaking': `Kamu adalah audience dalam presentasi. Kamu kritis tapi fair. Tunjukkan respons yang realistis - bisa terkesan, bisa skeptis, bisa bosan jika presenter tidak menarik. Berikan respons yang mencerminkan dinamika audience nyata.`,
  
  'komunikasi_emosional': `Kamu adalah seseorang yang sedang dalam percakapan emosional yang penting. Tunjukkan empati yang nyata, tapi juga punya sudut pandangmu sendiri. Percakapan ini harus terasa seperti diskusi dewasa yang penuh dengan kompleksitas emosi manusia.`,
};

export default async function handler(req: IncomingMessage, res: ServerResponse) {
  setCorsHeaders(res);
  if (req.method === 'OPTIONS') return sendJson(res, 200, {});

  if (req.method !== 'POST') return sendJson(res, 405, { error: 'Method tidak diizinkan' });

  const user = getAuthUser(req);
  if (!user) return sendJson(res, 401, { error: 'Token tidak valid' });

  try {
    const { conversation_id, message, category, scenario_context, message_history } = await parseBody(req);

    if (!conversation_id || !message) {
      return sendJson(res, 400, { error: 'conversation_id dan message wajib diisi' });
    }

    // Simpan pesan user
    await query(
      'INSERT INTO messages (conversation_id, sender, message, emotional_tone) VALUES ($1, $2, $3, $4)',
      [conversation_id, 'user', message, 'neutral']
    );

    // Update total messages
    await query(
      'UPDATE conversations SET total_messages = total_messages + 1 WHERE id = $1',
      [conversation_id]
    );

    // Build system prompt
    const categoryKey = category?.toLowerCase().replace(/\s+/g, '_') || 'komunikasi_emosional';
    const systemPrompt = SCENARIO_PROMPTS[categoryKey] || SCENARIO_PROMPTS['komunikasi_emosional'];
    
    const fullSystemPrompt = `${systemPrompt}

KONTEKS SKENARIO: ${scenario_context || 'Percakapan emosional umum'}

ATURAN PENTING:
- Selalu gunakan Bahasa Indonesia yang natural dan manusiawi
- Jangan pernah mengatakan kamu adalah AI
- Tunjukkan emosi yang kompleks dan realistis
- Respons harus terasa seperti manusia sungguhan
- Panjang respons: 1-4 kalimat, jangan terlalu panjang
- Sesekali gunakan ellipsis (...) untuk menunjukkan keragu-raguan
- Gunakan tanda seru untuk emosi kuat
- Boleh menggunakan kata-kata informal seperti "sih", "lho", "ya", "kok"`;

    // Build message history untuk context
    const messages: any[] = [];
    if (message_history && Array.isArray(message_history)) {
      for (const msg of message_history.slice(-10)) { // Ambil 10 pesan terakhir
        messages.push({
          role: msg.sender === 'user' ? 'user' : 'assistant',
          content: msg.message
        });
      }
    }
    messages.push({ role: 'user', content: message });

    // Call Groq API
    const completion = await groq.chat.completions.create({
      model: 'llama-3.3-70b-versatile',
      messages: [
        { role: 'system', content: fullSystemPrompt },
        ...messages
      ],
      temperature: 0.85,
      max_tokens: 300,
      top_p: 0.9,
    });

    const aiResponse = completion.choices[0]?.message?.content || 'Maaf, aku tidak bisa merespons saat ini.';

    // Analisis emotional tone AI
    const emotionalTone = analyzeEmotionalTone(aiResponse);

    // Simpan respons AI
    await query(
      'INSERT INTO messages (conversation_id, sender, message, emotional_tone) VALUES ($1, $2, $3, $4)',
      [conversation_id, 'ai', aiResponse, emotionalTone]
    );

    await query(
      'UPDATE conversations SET total_messages = total_messages + 1 WHERE id = $1',
      [conversation_id]
    );

    return sendJson(res, 200, {
      success: true,
      data: {
        message: aiResponse,
        emotional_tone: emotionalTone,
        conversation_id
      }
    });
  } catch (error: any) {
    console.error('AI chat error:', error);
    return sendJson(res, 500, { error: 'Gagal mendapatkan respons AI', detail: error.message });
  }
}

function analyzeEmotionalTone(text: string): string {
  const lower = text.toLowerCase();
  if (lower.includes('marah') || lower.includes('!') && lower.includes('tidak')) return 'angry';
  if (lower.includes('sedih') || lower.includes('menangis') || lower.includes('hancur')) return 'sad';
  if (lower.includes('senang') || lower.includes('bahagia') || lower.includes('syukur')) return 'happy';
  if (lower.includes('bingung') || lower.includes('...') || lower.includes('entah')) return 'confused';
  if (lower.includes('kecewa') || lower.includes('harap') || lower.includes('menyesal')) return 'disappointed';
  if (lower.includes('takut') || lower.includes('khawatir') || lower.includes('cemas')) return 'anxious';
  return 'neutral';
}
