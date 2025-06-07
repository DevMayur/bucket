# 🚀 Quick CORS Workaround for Development

If you need to test your Flutter Storage Bucket SDK immediately while waiting for server CORS configuration, here are some development workarounds:

## Method 1: Chrome with Disabled Security (Development Only)

**⚠️ WARNING: Only use this for development, never for production!**

### On macOS:
```bash
# Close all Chrome instances first
pkill "Google Chrome"

# Launch Chrome with disabled web security
open -n -a "Google Chrome" --args --user-data-dir=/tmp/chrome_dev_test --disable-web-security --disable-features=VizDisplayCompositor
```

### On Windows:
```cmd
# Close Chrome first, then run:
"C:\Program Files\Google\Chrome\Application\chrome.exe" --user-data-dir="C:\tmp\chrome_dev_test" --disable-web-security --disable-features=VizDisplayCompositor
```

### On Linux:
```bash
# Close Chrome first, then run:
google-chrome --user-data-dir="/tmp/chrome_dev_test" --disable-web-security --disable-features=VizDisplayCompositor
```

Then run your Flutter web app:
```bash
cd flutter_storage_bucket/example/flutter_example
flutter run -d chrome
```

## Method 2: Use Flutter Desktop Instead

Flutter desktop apps don't have CORS restrictions:

```bash
# Install macOS desktop support if not already done
flutter config --enable-macos-desktop

# Run on macOS (replace with your platform)
cd flutter_storage_bucket/example/flutter_example
flutter run -d macos
```

Available platforms:
- `flutter run -d macos` (macOS)
- `flutter run -d windows` (Windows)
- `flutter run -d linux` (Linux)

## Method 3: Browser Extension (Temporary)

Install a CORS extension for development:
- **Chrome**: "CORS Unblock" or "CORS Toggle"
- **Firefox**: "CORS Everywhere"

**⚠️ Remember to disable these extensions when browsing normally!**

## Method 4: Mobile Emulator

Use mobile emulators which don't have CORS restrictions:

```bash
# iOS Simulator
flutter run -d ios

# Android Emulator  
flutter run -d android
```

## Method 5: Simple Node.js Proxy

Create a quick proxy server (`proxy-server.js`):

```javascript
const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const cors = require('cors');

const app = express();
app.use(cors());

// Proxy API requests
app.use('/api', createProxyMiddleware({
  target: 'https://your-api-domain.com',
  changeOrigin: true,
  pathRewrite: {
    '^/api': '/api/v1', // Adjust path as needed
  },
}));

app.listen(3001, () => {
  console.log('Proxy server running on http://localhost:3001');
});
```

Install dependencies and run:
```bash
npm install express http-proxy-middleware cors
node proxy-server.js
```

Then update your Flutter app to use `http://localhost:3001` as the base URL.

## Testing Your Setup

1. Try the connection test in your Flutter app
2. Check browser console for CORS errors
3. Look at Network tab to see if requests are being made
4. If you see the CORS error dialog, the detection is working

## Next Steps

Once you confirm the Flutter SDK works with these workarounds:

1. Implement the permanent CORS solution on your server (see `CORS_SETUP_GUIDE.md`)
2. Test with the proper server configuration
3. Deploy your Flutter web app normally

---

Remember: These are development workarounds only. For production, always implement proper CORS headers on your server! 🔒 