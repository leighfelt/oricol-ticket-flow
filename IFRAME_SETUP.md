# Running the App as an Iframe

This guide explains how to embed the Oricol Helpdesk app as an iframe on your website.

## Prerequisites

1. The app must be deployed and accessible via a URL (see [GITHUB_SUPABASE_DEPLOYMENT.md](./GITHUB_SUPABASE_DEPLOYMENT.md))
2. Your website must support iframe embedding
3. HTTPS is strongly recommended for security

## Quick Start

### Basic Iframe Embedding

Add this HTML to your website:

```html
<iframe 
  src="https://your-app-url.com" 
  width="100%" 
  height="800px"
  frameborder="0"
  allow="clipboard-write; camera; microphone"
  sandbox="allow-same-origin allow-scripts allow-forms allow-popups allow-modals"
  title="Oricol Helpdesk"
></iframe>
```

Replace `https://your-app-url.com` with your deployed app URL.

## Deployment Options for Iframe Hosting

### Option 1: Netlify (Recommended)

**Why Netlify?**
- Free SSL certificate
- Custom domain support
- Easy iframe configuration
- Fast global CDN

**Setup:**
1. Deploy to Netlify following [GITHUB_SUPABASE_DEPLOYMENT.md](./GITHUB_SUPABASE_DEPLOYMENT.md)
2. Your app URL will be: `https://your-site-name.netlify.app`
3. Configure custom domain if desired

### Option 2: Vercel

**Setup:**
1. Deploy to Vercel following [GITHUB_SUPABASE_DEPLOYMENT.md](./GITHUB_SUPABASE_DEPLOYMENT.md)
2. Your app URL will be: `https://your-project.vercel.app`

### Option 3: Cloudflare Pages

**Setup:**
1. Deploy to Cloudflare Pages
2. Your app URL will be: `https://your-project.pages.dev`
3. Benefits: Unlimited bandwidth, DDoS protection

### Option 4: GitHub Pages

**Setup:**
1. Enable GitHub Pages deployment
2. Your app URL will be: `https://username.github.io/repository-name/`

**Note**: You may need to configure base URL for React Router:

Edit `vite.config.ts`:
```typescript
export default defineConfig({
  base: '/repository-name/',
  // ... rest of config
})
```

## Configuring the App for Iframe Usage

### 1. Update Content Security Policy

Add a `_headers` file for Netlify in the `public/` directory:

```
/*
  X-Frame-Options: SAMEORIGIN
  Content-Security-Policy: frame-ancestors 'self' https://yourdomain.com https://www.yourdomain.com
```

For Vercel, create `vercel.json`:

```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "X-Frame-Options",
          "value": "SAMEORIGIN"
        },
        {
          "key": "Content-Security-Policy",
          "value": "frame-ancestors 'self' https://yourdomain.com https://www.yourdomain.com"
        }
      ]
    }
  ]
}
```

**Important**: Replace `https://yourdomain.com` with your actual website domain.

### 2. Handle Authentication in Iframe

The app uses Supabase authentication, which works in iframes with proper configuration:

Update Supabase settings:
1. Go to your Supabase project
2. Navigate to **Authentication** → **URL Configuration**
3. Add your parent website domain to **Site URL**
4. Add redirect URLs:
   - `https://your-app-url.com/**`
   - `https://yourdomain.com/**`

### 3. Enable Third-Party Cookies (if needed)

Some browsers block third-party cookies in iframes. To handle this:

**Option A: Use SameSite=None** (Recommended)

Supabase handles this automatically for authentication cookies.

**Option B: Inform Users**

Add a notice on your website:
```html
<div class="iframe-notice">
  <p>If the helpdesk doesn't load, please enable third-party cookies for this site or 
  <a href="https://your-app-url.com" target="_blank">open in a new window</a>.</p>
</div>
```

## Advanced Iframe Configuration

### Responsive Iframe

```html
<style>
  .iframe-container {
    position: relative;
    width: 100%;
    padding-bottom: 75%; /* 4:3 Aspect Ratio */
    height: 0;
    overflow: hidden;
  }
  
  .iframe-container iframe {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    border: none;
  }
</style>

<div class="iframe-container">
  <iframe 
    src="https://your-app-url.com"
    allow="clipboard-write; camera; microphone"
    sandbox="allow-same-origin allow-scripts allow-forms allow-popups allow-modals"
    title="Oricol Helpdesk"
  ></iframe>
</div>
```

### Full-Screen Iframe

```html
<style>
  .fullscreen-iframe {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    border: none;
    z-index: 9999;
  }
</style>

<iframe 
  src="https://your-app-url.com"
  class="fullscreen-iframe"
  allow="clipboard-write; camera; microphone"
  sandbox="allow-same-origin allow-scripts allow-forms allow-popups allow-modals"
  title="Oricol Helpdesk"
></iframe>
```

### Modal/Popup Iframe

```html
<button onclick="openHelpdeskModal()">Open Helpdesk</button>

<div id="helpdesk-modal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 9999;">
  <div style="position: relative; width: 90%; height: 90%; margin: 5% auto; background: white;">
    <button onclick="closeHelpdeskModal()" style="position: absolute; top: 10px; right: 10px; z-index: 10000;">Close</button>
    <iframe 
      src="https://your-app-url.com"
      style="width: 100%; height: 100%; border: none;"
      allow="clipboard-write; camera; microphone"
      sandbox="allow-same-origin allow-scripts allow-forms allow-popups allow-modals"
      title="Oricol Helpdesk"
    ></iframe>
  </div>
</div>

<script>
  function openHelpdeskModal() {
    document.getElementById('helpdesk-modal').style.display = 'block';
  }
  
  function closeHelpdeskModal() {
    document.getElementById('helpdesk-modal').style.display = 'none';
  }
</script>
```

### Embedded Widget (Corner Button)

```html
<style>
  .helpdesk-widget {
    position: fixed;
    bottom: 20px;
    right: 20px;
    z-index: 9999;
  }
  
  .helpdesk-button {
    background: #3b82f6;
    color: white;
    padding: 15px 25px;
    border-radius: 50px;
    border: none;
    cursor: pointer;
    font-size: 16px;
    box-shadow: 0 4px 6px rgba(0,0,0,0.1);
  }
  
  .helpdesk-button:hover {
    background: #2563eb;
  }
  
  .helpdesk-iframe-container {
    display: none;
    position: fixed;
    bottom: 80px;
    right: 20px;
    width: 400px;
    height: 600px;
    background: white;
    border-radius: 10px;
    box-shadow: 0 10px 25px rgba(0,0,0,0.2);
    overflow: hidden;
  }
  
  .helpdesk-iframe-container.open {
    display: block;
  }
  
  .helpdesk-iframe-container iframe {
    width: 100%;
    height: 100%;
    border: none;
  }
</style>

<div class="helpdesk-widget">
  <button class="helpdesk-button" onclick="toggleHelpdesk()">
    Need Help?
  </button>
  <div id="helpdesk-iframe-container" class="helpdesk-iframe-container">
    <iframe 
      src="https://your-app-url.com"
      allow="clipboard-write; camera; microphone"
      sandbox="allow-same-origin allow-scripts allow-forms allow-popups allow-modals"
      title="Oricol Helpdesk"
    ></iframe>
  </div>
</div>

<script>
  function toggleHelpdesk() {
    const container = document.getElementById('helpdesk-iframe-container');
    container.classList.toggle('open');
  }
</script>
```

## Communication Between Parent and Iframe

### Send Messages to Iframe

From your website:
```javascript
const iframe = document.querySelector('iframe');
iframe.contentWindow.postMessage({
  type: 'USER_INFO',
  data: {
    email: 'user@example.com',
    name: 'John Doe'
  }
}, 'https://your-app-url.com');
```

### Receive Messages from Iframe

In your website:
```javascript
window.addEventListener('message', (event) => {
  // Verify origin for security
  if (event.origin !== 'https://your-app-url.com') return;
  
  if (event.data.type === 'TICKET_CREATED') {
    console.log('Ticket created:', event.data.ticketId);
    // Handle ticket creation
  }
});
```

To enable this in the app, you would need to add postMessage calls in the appropriate components.

## Security Considerations

### 1. Sandbox Attribute

The `sandbox` attribute restricts iframe capabilities. Use these values:

- `allow-same-origin`: Required for Supabase auth
- `allow-scripts`: Required for React app
- `allow-forms`: Required for form submission
- `allow-popups`: Required for OAuth flows
- `allow-modals`: Required for dialogs

### 2. Content Security Policy

Set strict CSP headers to allow only your domain to embed the app:

```
Content-Security-Policy: frame-ancestors 'self' https://yourdomain.com
```

### 3. HTTPS Only

Always serve both your website and the embedded app over HTTPS.

### 4. Cookie Settings

Ensure Supabase cookies work in iframe context:
- SameSite=None
- Secure flag enabled

## Troubleshooting

### Issue: Iframe doesn't load

**Possible causes:**
1. X-Frame-Options header blocking embedding
2. Content Security Policy blocking embedding
3. HTTPS/HTTP mismatch

**Solutions:**
- Check browser console for errors
- Verify CSP and X-Frame-Options headers
- Ensure both sites use HTTPS

### Issue: Authentication doesn't work

**Possible causes:**
1. Third-party cookies blocked
2. Incorrect redirect URLs in Supabase
3. SameSite cookie settings

**Solutions:**
- Configure Supabase redirect URLs correctly
- Instruct users to enable third-party cookies
- Use `SameSite=None; Secure` for cookies

### Issue: Iframe shows scroll bars

**Solution:**
```html
<iframe 
  src="https://your-app-url.com"
  scrolling="no"
  style="overflow: hidden;"
></iframe>
```

Or adjust iframe height dynamically.

### Issue: Iframe content not responsive

**Solution:**
Add viewport meta tag in your app's `index.html`:
```html
<meta name="viewport" content="width=device-width, initial-scale=1.0">
```

## Testing Your Iframe

### Local Testing

1. Deploy your app to production
2. Create a test HTML file:

```html
<!DOCTYPE html>
<html>
<head>
  <title>Iframe Test</title>
</head>
<body>
  <h1>Testing Helpdesk Iframe</h1>
  <iframe 
    src="https://your-app-url.com"
    width="100%"
    height="800px"
    frameborder="0"
  ></iframe>
</body>
</html>
```

3. Open the file in different browsers
4. Test authentication and functionality

### Browser Compatibility

Test in:
- Chrome/Edge (Chromium)
- Firefox
- Safari
- Mobile browsers

## Performance Optimization

### 1. Lazy Loading

Load the iframe only when needed:

```html
<iframe 
  src="https://your-app-url.com"
  loading="lazy"
></iframe>
```

### 2. Preconnect

Add to your website's `<head>`:

```html
<link rel="preconnect" href="https://your-app-url.com">
<link rel="dns-prefetch" href="https://your-app-url.com">
```

### 3. Reduce Initial Load

Consider showing a loading placeholder:

```html
<div id="iframe-placeholder">
  <p>Loading helpdesk...</p>
  <button onclick="loadIframe()">Click to load</button>
</div>

<script>
  function loadIframe() {
    const placeholder = document.getElementById('iframe-placeholder');
    const iframe = document.createElement('iframe');
    iframe.src = 'https://your-app-url.com';
    iframe.width = '100%';
    iframe.height = '800px';
    placeholder.replaceWith(iframe);
  }
</script>
```

## Example: WordPress Integration

For WordPress sites:

1. Install "Custom HTML" block or use a custom HTML widget
2. Add the iframe code:

```html
<iframe 
  src="https://your-app-url.com"
  width="100%"
  height="800px"
  frameborder="0"
  allow="clipboard-write"
  sandbox="allow-same-origin allow-scripts allow-forms allow-popups"
  title="Oricol Helpdesk"
></iframe>
```

3. Or use a plugin like "Iframe" for more control

## Example: Wix Integration

1. Add an "HTML iframe" element from the Add panel
2. Enter your app URL
3. Configure size and position
4. Publish your site

## Example: Squarespace Integration

1. Add a "Code" block
2. Paste the iframe HTML
3. Apply and save

## Summary Checklist

- [ ] App deployed to production with HTTPS
- [ ] CSP headers configured to allow your domain
- [ ] Supabase redirect URLs configured
- [ ] Iframe code added to your website
- [ ] Tested in multiple browsers
- [ ] Authentication working in iframe
- [ ] Responsive design verified
- [ ] Security headers configured

## Next Steps

1. Deploy your app following [GITHUB_SUPABASE_DEPLOYMENT.md](./GITHUB_SUPABASE_DEPLOYMENT.md)
2. Get your production URL
3. Configure CSP headers for iframe embedding
4. Add iframe code to your website
5. Test thoroughly before going live

## Support

For iframe-specific issues:
- Check browser console for errors
- Verify CSP and CORS settings
- Test in incognito mode to rule out cache issues
- Open an issue on GitHub for help
