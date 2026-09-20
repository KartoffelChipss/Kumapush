// @ts-check
import { defineConfig } from 'astro/config';
import { unified } from '@astrojs/markdown-remark';
import { remarkAlert } from 'remark-github-blockquote-alert';

// https://astro.build/config
export default defineConfig({
    site: 'https://kumapush.com',
    markdown: {
        processor: unified({ remarkPlugins: [remarkAlert] }),
        shikiConfig: {
            theme: 'css-variables',
        },
    },
});
