# MatrixLab Exchange - Web3 Innovation Platform

A modern, responsive Web3 platform featuring wallet integration, VPN detection, and a sleek cold-toned design.

## Features

- **Responsive Design**: Optimized for both desktop and mobile devices
- **Scroll Animations**: Smooth text transitions with opacity changes
- **VPN Detection**: Magic detection system requiring secure connection
- **MetaMask Integration**: Wallet connection with signature authentication
- **Modern UI**: Cold-toned, low-contrast design with transparency effects
- **Dashboard**: Access to trading center, lab news, and developer profile

## Technology Stack

- **Frontend**: HTML5, CSS3, Vanilla JavaScript
- **Backend**: Node.js, Express
- **Blockchain**: Web3, MetaMask
- **Design**: Responsive, mobile-first approach

## Installation

```bash
npm install
```

## Running the Application

Development mode (port 3104):
```bash
npm start
```

Or specify a different port:
```bash
PORT=3105 npm start
```

## SSL Configuration

For production with Let's Encrypt and domain configuration, see the deployment section below.

## Project Structure

```
├── public/
│   ├── index.html      # Main HTML file
│   ├── styles.css      # Styling with cold-toned theme
│   └── app.js          # JavaScript logic
├── server.js           # Express server
├── package.json        # Dependencies
└── README.md          # Documentation
```

## Features Implementation

### 1. Landing Page
- Multi-section scroll experience
- Text slides in from left and right
- Opacity transitions on scroll
- Color changes between sections

### 2. VPN Detection
- WebRTC leak detection
- Connection timing analysis
- IP reputation checking
- Multi-factor verification

### 3. MetaMask Integration
- Automatic detection
- Mobile browser support
- Signature-based authentication
- Account change handling

### 4. Dashboard
- StableGuard Trading Center (in development)
- Laboratory News & Achievements
- MatrixLab Official Website link
- Developer Profile link

## Browser Support

- Chrome/Edge (recommended)
- Firefox
- Safari
- Mobile browsers (iOS Safari, Chrome Mobile)
- MetaMask in-app browser

## Security

- VPN requirement for access
- Wallet signature authentication
- No private key storage
- Secure connection handling

## License

MIT License - MatrixLab 2024
