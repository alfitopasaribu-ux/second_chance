"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.verifyToken = verifyToken;
exports.generateToken = generateToken;
exports.getAuthUser = getAuthUser;
exports.setCorsHeaders = setCorsHeaders;
exports.sendJson = sendJson;
exports.parseBody = parseBody;
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
function verifyToken(token) {
    const secret = process.env.JWT_SECRET;
    if (!secret)
        throw new Error('JWT_SECRET not defined');
    return jsonwebtoken_1.default.verify(token, secret);
}
function generateToken(payload) {
    const secret = process.env.JWT_SECRET;
    if (!secret)
        throw new Error('JWT_SECRET not defined');
    return jsonwebtoken_1.default.sign(payload, secret, { expiresIn: '7d' });
}
function getAuthUser(req) {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader || !authHeader.startsWith('Bearer '))
            return null;
        const token = authHeader.substring(7);
        return verifyToken(token);
    }
    catch {
        return null;
    }
}
function setCorsHeaders(res) {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
}
function sendJson(res, statusCode, data) {
    res.setHeader('Content-Type', 'application/json');
    res.statusCode = statusCode;
    res.end(JSON.stringify(data));
}
async function parseBody(req) {
    return new Promise((resolve, reject) => {
        let body = '';
        req.on('data', chunk => { body += chunk.toString(); });
        req.on('end', () => {
            try {
                resolve(body ? JSON.parse(body) : {});
            }
            catch {
                resolve({});
            }
        });
        req.on('error', reject);
    });
}
//# sourceMappingURL=auth.js.map