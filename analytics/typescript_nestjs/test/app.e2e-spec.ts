import { INestApplication } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { PrismaClient } from '@prisma/client';
import request from 'supertest';
import { AppModule } from '../src/app.module';

describe('Impression/Click API (e2e)', () => {
  let app: INestApplication;
  const prisma = new PrismaClient();

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  beforeEach(async () => {
    await prisma.eventRaw.deleteMany();
  });

  afterAll(async () => {
    await prisma.$disconnect();
    await app.close();
  });

  const eventPayload = (overrides: Record<string, any> = {}) => ({
    event_id: crypto.randomUUID(),
    type: 'impression',
    campaign_id: 'camp_123',
    creative_id: 'cr_456',
    source: 'web',
    occurred_at: '2026-02-10T21:10:00Z',
    user_id: 'u_999',
    metadata: { ip: '1.2.3.4' },
    ...overrides,
  });

  it('POST /events accepts valid payload', async () => {
    await request(app.getHttpServer())
      .post('/events')
      .send(eventPayload())
      .expect(202);
  });

  it('POST /events rejects invalid payload', async () => {
    await request(app.getHttpServer())
      .post('/events')
      .send(eventPayload({ type: 'unsupported' }))
      .expect(422)
      .expect((response) => {
        expect(response.body.errors.type).toBeDefined();
      });
  });

  it('GET /stats returns minute series with expected counts', async () => {
    await request(app.getHttpServer())
      .post('/events')
      .send(
        eventPayload({
          type: 'impression',
          occurred_at: '2026-02-10T21:10:00Z',
        }),
      )
      .expect(202);

    await request(app.getHttpServer())
      .post('/events')
      .send(
        eventPayload({ type: 'click', occurred_at: '2026-02-10T21:10:10Z' }),
      )
      .expect(202);

    await request(app.getHttpServer())
      .post('/events')
      .send(
        eventPayload({
          type: 'impression',
          occurred_at: '2026-02-10T21:11:10Z',
        }),
      )
      .expect(202);

    await request(app.getHttpServer())
      .get('/stats')
      .query({
        campaign_id: 'camp_123',
        from: '2026-02-10T21:10:00Z',
        to: '2026-02-10T21:11:00Z',
        granularity: 'minute',
      })
      .expect(200)
      .expect((response) => {
        expect(response.body.series).toEqual([
          { ts: '2026-02-10T21:10:00.000Z', impressions: 1, clicks: 1 },
          { ts: '2026-02-10T21:11:00.000Z', impressions: 1, clicks: 0 },
        ]);
      });
  });
});
