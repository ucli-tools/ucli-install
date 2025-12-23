# UCLI Tools Install Website

The official installation website for UCLI Tools. Provides a beautiful, simple interface for users to install the UCLI tool manager with a single command. Built with Astro and deployed to GitHub Pages.

## 🌐 Live Website

Visit [install.ucli.tools](https://install.ucli.tools) to install UCLI Tools.

## 🚀 Features

- **One-Click Installation**: Simple copy-paste installation command
- **Copy to Clipboard**: Easy copying of the install command with visual feedback
- **Responsive Design**: Works beautifully on desktop and mobile
- **Ecosystem Overview**: Links to all UCLI Tools services
- **Fast & Lightweight**: Static site with excellent performance

## 🛠️ Technology Stack

- **Framework**: [Astro](https://astro.build/) - Modern web framework
- **Styling**: [Tailwind CSS](https://tailwindcss.com/) - Utility-first CSS
- **Icons**: Custom SVG icons
- **Deployment**: GitHub Pages with automated CI/CD

## 📁 Project Structure

```
ucli-install/
├── public/                         # Static assets
│   ├── favicon.svg                # Site favicon
│   └── CNAME                      # Custom domain configuration
├── src/
│   └── pages/
│       └── index.astro           # Main install page
├── astro.config.mjs              # Astro configuration
├── tailwind.config.mjs           # Tailwind configuration
├── package.json                  # Dependencies and scripts
├── install.sh                    # The actual install script
└── README.md                     # This file
```

## 🏃‍♂️ Development

### Prerequisites

- Node.js 18+
- npm or yarn

### Local Development

1. **Clone the repository:**
   ```bash
   git clone https://github.com/ucli-tools/ucli-install.git
   cd ucli-install
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Start development server:**
   ```bash
   npm run dev
   ```

4. **Open your browser** to `http://localhost:4321`

The development server supports hot reloading - changes will be reflected immediately.

### Build for Production

```bash
npm run build
```

This creates a `dist/` directory with the production build.

### Preview Production Build

```bash
npm run preview
```

Serves the production build locally for testing.

## 🚀 Deployment

### Automatic Deployment

The website is automatically deployed to GitHub Pages when changes are pushed to the `main` branch via GitHub Actions.

### Manual Deployment

```bash
# Build the site
npm run build

# The dist/ folder contains the built site ready for deployment
```

## 🔧 Configuration

### Custom Domain

The site is configured to deploy to `install.ucli.tools` via the `public/CNAME` file.

## 🎨 Design

The site features a beautiful gradient background with glassmorphism effects, using an orange/yellow color scheme that matches the UCLI Tools brand.

- **Background**: Orange to amber gradient
- **Accent Colors**: Yellow and orange tones
- **Typography**: Clean, modern fonts
- **Effects**: Backdrop blur and subtle animations

## 📊 Installation Command

The site provides the following installation command:

```bash
curl -fsSL https://install.ucli.tools/install.sh | bash
```

This command:
- Downloads the install script from `install.ucli.tools`
- Pipes it to bash for execution
- Installs the UCLI tool manager system-wide

## 🔗 Ecosystem Links

The site provides quick access to:
- **UCLI Tools**: Main website ([ucli.tools](https://ucli.tools))
- **Registry**: Browse available tools ([registry.ucli.tools](https://registry.ucli.tools))
- **Documentation**: Guides and references ([docs.ucli.tools](https://docs.ucli.tools))

## 🤝 Contributing

### Code Contributions

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-feature`
3. Make your changes
4. Test locally: `npm run dev`
5. Commit and push your changes
6. Submit a pull request

### Content Updates

- Ensure the installation command remains accurate
- Keep ecosystem links up to date
- Maintain responsive design across all devices

## 📈 Performance

- **Lighthouse Score**: Targets 90+ on all metrics
- **Bundle Size**: Optimized with Astro's built-in optimizations
- **Loading Speed**: Fast initial page loads with minimal JavaScript

## 🐛 Troubleshooting

### Common Issues

**Build fails:**
```bash
# Clear cache and reinstall
rm -rf node_modules package-lock.json
npm install
```

### Getting Help

- **Issues**: [GitHub Issues](https://github.com/ucli-tools/ucli-install/issues)
- **Documentation**: [docs.ucli.tools](https://docs.ucli.tools)

## 📄 License

Licensed under the Apache License 2.0. See [LICENSE](../LICENSE) for details.

---

**Ready to install UCLI Tools?** Visit [install.ucli.tools](https://install.ucli.tools) or run the command above!
