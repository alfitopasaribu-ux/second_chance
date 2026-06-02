"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sql = void 0;
exports.query = query;
const serverless_1 = require("@neondatabase/serverless");
const connectionString = process.env.DATABASE_URL;
if (!connectionString) {
    throw new Error('DATABASE_URL is not defined. Pastikan .env.local sudah diisi.');
}
exports.sql = (0, serverless_1.neon)(connectionString);
async function query(queryText, params) {
    try {
        const result = params
            ? await (0, exports.sql)(queryText, params)
            : await (0, exports.sql)(queryText);
        return result;
    }
    catch (error) {
        console.error('❌ Database query error:', error?.message || error);
        throw error;
    }
}
//# sourceMappingURL=neon.js.map