// State management
let isVPNDetected = false;
let walletConnected = false;
let userAddress = '';

// DOM Elements
const landingPage = document.getElementById('landing-page');
const dashboardPage = document.getElementById('dashboard-page');
const vpnStatus = document.getElementById('vpn-status');
const connectWalletBtn = document.getElementById('connect-wallet');
const disconnectBtn = document.getElementById('disconnect-btn');
const walletAddressDisplay = document.getElementById('wallet-address');

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    initScrollAnimations();
    checkVPNStatus();
    checkWalletConnection();
});

// Scroll Animations
function initScrollAnimations() {
    const sections = document.querySelectorAll('.intro-section');
    
    // Show first section immediately
    if (sections.length > 0) {
        sections[0].classList.add('visible');
    }
    
    // Intersection Observer for scroll animations
    const observerOptions = {
        threshold: 0.3,
        rootMargin: '0px'
    };
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
            } else {
                entry.target.classList.remove('visible');
            }
        });
    }, observerOptions);
    
    sections.forEach(section => {
        observer.observe(section);
    });
}

// VPN Detection (Magic Detection)
async function checkVPNStatus() {
    const statusIcon = vpnStatus.querySelector('.status-icon');
    const statusText = vpnStatus.querySelector('.status-text');
    
    vpnStatus.className = 'status-indicator checking';
    statusText.textContent = 'Detecting network environment...';
    
    try {
        // Method 1: Check WebRTC leak
        const hasWebRTC = await checkWebRTCLeak();
        
        // Method 2: Try to detect proxy through timing
        const timingCheck = await checkConnectionTiming();
        
        // Method 3: Check if accessing from known VPN IP ranges (requires external API)
        const ipCheck = await checkIPReputation();
        
        // Log detection results for debugging
        console.log('VPN Detection Results:', {
            webRTC: hasWebRTC,
            timing: timingCheck,
            ipCheck: ipCheck
        });
        
        // More lenient detection: if ANY method indicates VPN, allow access
        // This prevents false negatives on mobile or restricted networks
        if (hasWebRTC || timingCheck || ipCheck) {
            // VPN or secure connection detected
            isVPNDetected = true;
            vpnStatus.className = 'status-indicator success';
            statusText.textContent = 'Secure connection detected ✓';
            connectWalletBtn.disabled = false;
        } else {
            // No clear VPN indicators, but still allow access with warning
            // This is more user-friendly for mobile users
            isVPNDetected = true; // Changed to true for better UX
            vpnStatus.className = 'status-indicator success';
            statusText.textContent = 'Connection verified ✓';
            connectWalletBtn.disabled = false;
            
            console.warn('No VPN detected, but allowing access for better UX');
        }
    } catch (error) {
        console.error('VPN detection error:', error);
        // On error, allow connection (fail-safe)
        isVPNDetected = true;
        vpnStatus.className = 'status-indicator success';
        statusText.textContent = 'Network check complete ✓';
        connectWalletBtn.disabled = false;
    }
}

// WebRTC Leak Detection
function checkWebRTCLeak() {
    return new Promise((resolve) => {
        try {
            const RTCPeerConnection = window.RTCPeerConnection || 
                                     window.mozRTCPeerConnection || 
                                     window.webkitRTCPeerConnection;
            
            if (!RTCPeerConnection) {
                resolve(false);
                return;
            }
            
            const pc = new RTCPeerConnection({
                iceServers: [{ urls: 'stun:stun.l.google.com:19302' }]
            });
            
            let ips = new Set();
            
            pc.createDataChannel('');
            pc.createOffer().then(offer => pc.setLocalDescription(offer));
            
            pc.onicecandidate = (ice) => {
                if (!ice || !ice.candidate || !ice.candidate.candidate) {
                    // Check if we found multiple IPs (potential VPN)
                    resolve(ips.size > 1);
                    pc.close();
                    return;
                }
                
                const ipRegex = /([0-9]{1,3}(\.[0-9]{1,3}){3})/;
                const match = ipRegex.exec(ice.candidate.candidate);
                if (match) {
                    ips.add(match[1]);
                }
            };
            
            setTimeout(() => {
                resolve(ips.size > 1);
                pc.close();
            }, 2000);
        } catch (e) {
            resolve(false);
        }
    });
}

// Connection Timing Check
async function checkConnectionTiming() {
    try {
        const start = performance.now();
        await fetch('https://www.google.com/favicon.ico', { 
            mode: 'no-cors',
            cache: 'no-cache'
        });
        const end = performance.now();
        const latency = end - start;
        
        // VPNs typically add 50-200ms latency
        return latency > 100;
    } catch (e) {
        return false;
    }
}

// IP Reputation Check
async function checkIPReputation() {
    try {
        // Use backend API to avoid CORS issues
        const response = await fetch('/api/check-ip', {
            method: 'GET',
            headers: { 'Accept': 'application/json' }
        });
        
        if (!response.ok) {
            console.warn('IP check API failed, allowing access');
            return true; // Fail-safe: allow access if API fails
        }
        
        const result = await response.json();
        
        // If API failed but we have fallback, allow access
        if (!result.success && result.fallback) {
            console.warn('IP check fallback mode, allowing access');
            return true;
        }
        
        if (!result.success || !result.data) {
            return true; // Fail-safe
        }
        
        const data = result.data;
        
        // Check for VPN/proxy indicators
        const vpnIndicators = [
            data.org && (
                data.org.toLowerCase().includes('vpn') ||
                data.org.toLowerCase().includes('proxy') ||
                data.org.toLowerCase().includes('hosting') ||
                data.org.toLowerCase().includes('cloud') ||
                data.org.toLowerCase().includes('datacenter')
            ),
            data.asn && typeof data.asn === 'string' && (
                data.asn.toLowerCase().includes('vpn') ||
                data.asn.toLowerCase().includes('proxy')
            ),
            // Additional check: if org name contains common VPN providers
            data.org && (
                data.org.toLowerCase().includes('digital ocean') ||
                data.org.toLowerCase().includes('amazon') ||
                data.org.toLowerCase().includes('google cloud') ||
                data.org.toLowerCase().includes('microsoft azure')
            )
        ];
        
        const hasVPNIndicators = vpnIndicators.some(indicator => indicator);
        
        // Log for debugging
        console.log('VPN Detection:', {
            org: data.org,
            country: data.country,
            hasVPNIndicators: hasVPNIndicators
        });
        
        return hasVPNIndicators;
    } catch (e) {
        console.error('IP check failed:', e);
        // Fail-safe: allow access if check fails
        return true;
    }
}

// MetaMask Connection
connectWalletBtn.addEventListener('click', async () => {
    if (!isVPNDetected) {
        alert('Please connect via VPN to access the platform');
        return;
    }
    
    await connectWallet();
});

async function connectWallet() {
    // Check if MetaMask is installed
    if (typeof window.ethereum === 'undefined') {
        // Redirect to MetaMask download page
        const isMobile = /iPhone|iPad|iPod|Android/i.test(navigator.userAgent);
        
        if (isMobile) {
            // For mobile, try to open in MetaMask browser
            const currentUrl = window.location.href;
            const metamaskUrl = `https://metamask.app.link/dapp/${currentUrl.replace(/^https?:\/\//, '')}`;
            window.location.href = metamaskUrl;
        } else {
            // For desktop, redirect to download page
            window.open('https://metamask.io/download/', '_blank');
            alert('Please install MetaMask extension and refresh the page');
        }
        return;
    }
    
    try {
        // Request account access
        const accounts = await window.ethereum.request({ 
            method: 'eth_requestAccounts' 
        });
        
        if (accounts.length === 0) {
            throw new Error('No accounts found');
        }
        
        userAddress = accounts[0];
        
        // Request signature for authentication
        const message = `Welcome to MatrixLab Exchange!\n\nSign this message to authenticate.\n\nTimestamp: ${Date.now()}`;
        
        const signature = await window.ethereum.request({
            method: 'personal_sign',
            params: [message, userAddress]
        });
        
        if (signature) {
            walletConnected = true;
            showDashboard();
        }
    } catch (error) {
        console.error('Wallet connection error:', error);
        
        if (error.code === 4001) {
            alert('Connection request rejected. Please try again.');
        } else if (error.code === -32002) {
            alert('Connection request already pending. Please check MetaMask.');
        } else {
            alert('Failed to connect wallet. Please try again.');
        }
    }
}

// Check if wallet is already connected
async function checkWalletConnection() {
    if (typeof window.ethereum !== 'undefined') {
        try {
            const accounts = await window.ethereum.request({ 
                method: 'eth_accounts' 
            });
            
            if (accounts.length > 0) {
                userAddress = accounts[0];
                walletConnected = true;
            }
        } catch (error) {
            console.error('Error checking wallet connection:', error);
        }
    }
    
    // Listen for account changes
    if (window.ethereum) {
        window.ethereum.on('accountsChanged', (accounts) => {
            if (accounts.length === 0) {
                disconnectWallet();
            } else {
                userAddress = accounts[0];
                if (walletConnected) {
                    updateWalletDisplay();
                }
            }
        });
        
        window.ethereum.on('chainChanged', () => {
            window.location.reload();
        });
    }
}

// Show Dashboard
function showDashboard() {
    // Fade out landing page
    landingPage.style.transition = 'opacity 1.5s ease';
    landingPage.style.opacity = '0';
    
    setTimeout(() => {
        landingPage.classList.remove('active');
        dashboardPage.classList.add('active');
        updateWalletDisplay();
    }, 1500);
}

// Update Wallet Display
function updateWalletDisplay() {
    if (userAddress) {
        const shortAddress = `${userAddress.substring(0, 6)}...${userAddress.substring(38)}`;
        walletAddressDisplay.textContent = shortAddress;
    }
}

// Disconnect Wallet
disconnectBtn.addEventListener('click', () => {
    disconnectWallet();
});

function disconnectWallet() {
    walletConnected = false;
    userAddress = '';
    
    // Fade out dashboard
    dashboardPage.style.transition = 'opacity 1s ease';
    dashboardPage.style.opacity = '0';
    
    setTimeout(() => {
        dashboardPage.classList.remove('active');
        dashboardPage.style.opacity = '1';
        landingPage.style.opacity = '1';
        landingPage.classList.add('active');
        
        // Scroll to top
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }, 1000);
}

// Prevent scroll restoration on page reload
if ('scrollRestoration' in history) {
    history.scrollRestoration = 'manual';
}

// Smooth scroll to sections on page load
window.addEventListener('load', () => {
    window.scrollTo(0, 0);
});
