import { Body, Controller, Get, Post, Query, Res } from '@nestjs/common';
import type { Response } from 'express';
import { PrismaService } from './prisma.service';

@Controller()
export class AppController {
  constructor(private readonly prisma: PrismaService) {}

  @Post('events')
  async createEvent(@Body() body: any, @Res() res: Response) {
    try {
      const requiredFields = [
        'event_id',
        'type',
        'campaign_id',
        'source',
        'occurred_at',
      ];
      const missing = requiredFields.filter((field) => !body?.[field]);

      if (missing.length > 0) {
        return res.status(422).json({ errors: { required: missing } });
      }

      if (body.type !== 'impression' && body.type !== 'click') {
        return res
          .status(422)
          .json({ errors: { type: ['must be impression or click'] } });
      }

      const occurredAt = new Date(body.occurred_at);
      if (
        Number.isNaN(occurredAt.getTime()) ||
        !String(body.occurred_at).endsWith('Z')
      ) {
        return res
          .status(422)
          .json({
            errors: { occurred_at: ['must be a valid ISO8601 UTC datetime'] },
          });
      }

      await this.prisma.eventRaw.create({
        data: {
          event_id: String(body.event_id),
          type: String(body.type),
          campaign_id: String(body.campaign_id),
          creative_id: body.creative_id ? String(body.creative_id) : null,
          source: String(body.source),
          occurred_at: occurredAt,
          user_id: body.user_id ? String(body.user_id) : null,
          metadata: body.metadata ?? null,
        },
      });

      return res.status(202).send('');
    } catch (_error) {
      return res.status(500).json({ error: 'internal server error' });
    }
  }

  @Get('stats')
  async getStats(@Query() query: any, @Res() res: Response) {
    try {
      const requiredFields = ['campaign_id', 'from', 'to', 'granularity'];
      const missing = requiredFields.filter((field) => !query?.[field]);

      if (missing.length > 0) {
        return res.status(422).json({ errors: { required: missing } });
      }

      if (query.granularity !== 'minute') {
        return res
          .status(422)
          .json({ errors: { granularity: ['must be minute'] } });
      }

      const fromDate = new Date(query.from);
      const toDate = new Date(query.to);

      if (
        Number.isNaN(fromDate.getTime()) ||
        Number.isNaN(toDate.getTime()) ||
        !String(query.from).endsWith('Z') ||
        !String(query.to).endsWith('Z')
      ) {
        return res.status(422).json({ errors: { query: ['invalid query'] } });
      }

      if (fromDate.getTime() > toDate.getTime()) {
        return res
          .status(422)
          .json({ errors: { from: ['must be less than or equal to to'] } });
      }

      const fromMinute = this.truncateToMinute(fromDate);
      const toMinute = this.truncateToMinute(toDate);
      const toEndOfMinute = new Date(toMinute.getTime() + 59_000);

      const events = await this.prisma.eventRaw.findMany({
        where: {
          campaign_id: String(query.campaign_id),
          occurred_at: {
            gte: fromMinute,
            lte: toEndOfMinute,
          },
        },
        orderBy: {
          occurred_at: 'asc',
        },
        select: {
          occurred_at: true,
          type: true,
        },
      });

      const byMinute: Record<
        string,
        { ts: string; impressions: number; clicks: number }
      > = {};

      for (const event of events) {
        const bucket = this.truncateToMinute(event.occurred_at).toISOString();

        if (!byMinute[bucket]) {
          byMinute[bucket] = {
            ts: bucket,
            impressions: 0,
            clicks: 0,
          };
        }

        if (event.type === 'click') {
          byMinute[bucket].clicks += 1;
        } else {
          byMinute[bucket].impressions += 1;
        }
      }

      const series = Object.values(byMinute).sort((a, b) =>
        a.ts.localeCompare(b.ts),
      );

      return res.status(200).json({
        campaign_id: String(query.campaign_id),
        from: fromDate.toISOString(),
        to: toDate.toISOString(),
        granularity: 'minute',
        series,
      });
    } catch (_error) {
      return res.status(500).json({ error: 'internal server error' });
    }
  }

  private truncateToMinute(date: Date) {
    const normalized = new Date(date);
    normalized.setUTCSeconds(0, 0);
    return normalized;
  }
}
