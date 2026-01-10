import { Request, Response, NextFunction } from 'express';
import morgan from 'morgan';

export const logger = morgan('combined', {
  skip: (_req: Request, res: Response) => {
    return res.statusCode < 400;
  },
});

export const requestLogger = (req: Request, res: Response, next: NextFunction): void => {
  const start = Date.now();

  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`([LOG request] ========= ${req.method} ${req.path} - ${res.statusCode} - ${duration}ms)`);
  });

  next();
};

