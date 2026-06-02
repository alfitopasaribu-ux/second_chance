import { IncomingMessage, ServerResponse } from 'http';
import bcrypt from 'bcryptjs';
import { query } from '../../lib/neon';
import { generateToken, setCorsHeaders, sendJson, parseBody } from '../../lib/auth';

export default async function handler(req: IncomingMessage, res: ServerResponse) {
  setCorsHeaders(res);
  if (req.method === 'OPTIONS') return sendJson(res, 200, {});

  if (req.method !== 'POST') {
    return sendJson(res, 405, { error: 'Method tidak diizinkan' });
  }

  try {
    const { username, email, password } = await parseBody(req);

    if (!username || !email || !password) {
      return sendJson(res, 400, { error: 'Username, email, dan password wajib diisi' });
    }

    if (password.length < 6) {
      return sendJson(res, 400, { error: 'Password minimal 6 karakter' });
    }

    // Cek apakah email/username sudah ada
    const existing = await query(
      'SELECT id FROM users WHERE email = $1 OR username = $2 LIMIT 1',
      [email, username]
    );

    if (existing.length > 0) {
      return sendJson(res, 409, { error: 'Email atau username sudah terdaftar' });
    }

    // Hash password
    const passwordHash = await bcrypt.hash(password, 10);

    // Insert user
    const users = await query(
      'INSERT INTO users (username, email, password_hash) VALUES ($1, $2, $3) RETURNING id, username, email, created_at',
      [username, email, passwordHash]
    );

    const user = users[0];
    const token = generateToken({ userId: user.id, email: user.email, username: user.username });

    return sendJson(res, 201, {
      success: true,
      message: 'Akun berhasil dibuat! Selamat datang di Second Chance.',
      token,
      user: { id: user.id, username: user.username, email: user.email }
    });
  } catch (error: any) {
    console.error('Register error:', error);
    return sendJson(res, 500, { error: 'Terjadi kesalahan server' });
  }
}
