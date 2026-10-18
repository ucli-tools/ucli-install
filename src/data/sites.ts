// The four ucli sites, in the order of ucli-kit/sites.txt. The top bar loops over navLabel and the
// footer over footerLabel, so each URL exists once. GitHub is a fixed last footer entry (SiteFooter).
export type SiteKey = 'home' | 'install' | 'registry' | 'docs';

export const SITES: { key: SiteKey; navLabel: string; footerLabel: string; href: string }[] = [
  { key: 'home', navLabel: 'Home', footerLabel: 'ucli.tools', href: 'https://ucli.tools/' },
  { key: 'install', navLabel: 'Install', footerLabel: 'install.ucli.tools', href: 'https://install.ucli.tools/' },
  { key: 'registry', navLabel: 'Registry', footerLabel: 'registry.ucli.tools', href: 'https://registry.ucli.tools/' },
  { key: 'docs', navLabel: 'Docs', footerLabel: 'docs.ucli.tools', href: 'https://docs.ucli.tools/' },
];

export const GITHUB_URL = 'https://github.com/ucli-tools/ucli';
