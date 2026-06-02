import { neon } from '@neondatabase/serverless';

const connectionString = process.env.DATABASE_URL;

if (!connectionString) {
  throw new Error('DATABASE_URL is not defined. Pastikan .env.local sudah diisi.');
}

export const sql = neon(connectionString);

export async function query<T = any>(
  queryText: string,
  params?: any[]
): Promise<T[]> {
  try {
    const result = params
      ? await sql(queryText, params)
      : await sql(queryText);
    return result as T[];
  } catch (error: any) {
    console.error('❌ Database query error:', error?.message || error);
    throw error;
  }
}
