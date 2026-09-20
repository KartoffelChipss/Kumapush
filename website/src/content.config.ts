import { defineCollection } from 'astro:content';
import { z } from 'astro/zod';
import { glob } from 'astro/loaders';

const docs = defineCollection({
    loader: glob({ base: './src/content/docs', pattern: '**/*.md' }),
    schema: z.object({
        title: z.string(),
        description: z.string().optional(),
        group: z.string().optional(),
        groupOrder: z.number().optional(),
        order: z.number().optional(),
    }),
});

const legal = defineCollection({
    loader: glob({ base: './src/content/legal', pattern: '**/*.md' }),
    schema: z.object({
        title: z.string(),
        description: z.string().optional(),
    }),
});

export const collections = { docs, legal };
