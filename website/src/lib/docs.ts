import type { CollectionEntry } from 'astro:content';

export type DocEntry = CollectionEntry<'docs'>;

export function docHref(id: string): string {
    return id === 'index' ? '/docs' : `/docs/${id}`;
}

export interface SidebarSection {
    title: string | null;
    entries: DocEntry[];
}

function sortEntries(entries: DocEntry[]): DocEntry[] {
    return [...entries].sort((a, b) => {
        const orderDiff = (a.data.order ?? Infinity) - (b.data.order ?? Infinity);
        if (orderDiff !== 0) return orderDiff;
        return a.data.title.localeCompare(b.data.title);
    });
}

export function getSidebarSections(docs: DocEntry[]): SidebarSection[] {
    const pages = docs.filter((doc) => doc.id !== 'index');

    const ungrouped = sortEntries(pages.filter((doc) => !doc.data.group));

    const groupNames = [
        ...new Set(pages.filter((doc) => doc.data.group).map((doc) => doc.data.group as string)),
    ];
    groupNames.sort((a, b) => {
        const entriesA = pages.filter((doc) => doc.data.group === a);
        const entriesB = pages.filter((doc) => doc.data.group === b);
        const orderA = Math.min(...entriesA.map((doc) => doc.data.groupOrder ?? Infinity));
        const orderB = Math.min(...entriesB.map((doc) => doc.data.groupOrder ?? Infinity));
        if (orderA !== orderB) return orderA - orderB;
        return a.localeCompare(b);
    });

    const sections: SidebarSection[] = [];
    if (ungrouped.length > 0) sections.push({ title: null, entries: ungrouped });
    for (const name of groupNames) {
        sections.push({
            title: name,
            entries: sortEntries(pages.filter((doc) => doc.data.group === name)),
        });
    }

    return sections;
}

export function getFlatOrder(docs: DocEntry[]): DocEntry[] {
    const indexEntry = docs.find((doc) => doc.id === 'index');
    const rest = getSidebarSections(docs).flatMap((section) => section.entries);
    return indexEntry ? [indexEntry, ...rest] : rest;
}

export interface PrevNext {
    prev: DocEntry | null;
    next: DocEntry | null;
}

export function getPrevNext(docs: DocEntry[], currentId: string): PrevNext {
    const order = getFlatOrder(docs);
    const index = order.findIndex((doc) => doc.id === currentId);
    if (index === -1) return { prev: null, next: null };
    return {
        prev: index > 0 ? order[index - 1] : null,
        next: index < order.length - 1 ? order[index + 1] : null,
    };
}
