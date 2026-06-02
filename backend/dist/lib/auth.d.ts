import { IncomingMessage, ServerResponse } from 'http';
export interface JWTPayload {
    userId: string;
    email: string;
    username: string;
}
export declare function verifyToken(token: string): JWTPayload;
export declare function generateToken(payload: JWTPayload): string;
export declare function getAuthUser(req: IncomingMessage): JWTPayload | null;
export declare function setCorsHeaders(res: ServerResponse): void;
export declare function sendJson(res: ServerResponse, statusCode: number, data: any): void;
export declare function parseBody(req: IncomingMessage): Promise<any>;
//# sourceMappingURL=auth.d.ts.map