export const handleViewDeal = (dealUrl: string) => {
  console.log('handleViewDeal called with URL:', dealUrl);

  const isAndroid = /Android/i.test(navigator.userAgent);
  const isIOS = /iPhone|iPad|iPod/i.test(navigator.userAgent);

  if (isAndroid) {
    // Android deep link handling
    const packageName = 'com.amazon.mShop.android.shopping';
    const intentUrl = `intent://${dealUrl.replace('https://', '')}#Intent;scheme=https;package=${packageName};end`;
    
    // Try to open Play Store if app not installed
    window.location.href = intentUrl;
    setTimeout(() => {
      window.location.href = `market://details?id=${packageName}`;
    }, 250);

  } else if (isIOS) {
    // iOS deep link handling with proper fallback
    const appScheme = 'amzn://';
    const appUrl = `${appScheme}${dealUrl.replace('https://www.amazon.com/', '')}`;
    
    // Create hidden iframe for silent app detection
    const iframe = document.createElement('iframe');
    iframe.style.display = 'none';
    iframe.src = appUrl;
    
    // Set up timeout for web fallback
    const timeout = setTimeout(() => {
      window.location.href = dealUrl;
      document.body.removeChild(iframe);
    }, 500);

    // Add iframe to DOM
    iframe.onload = () => {
      clearTimeout(timeout);
      document.body.removeChild(iframe);
    };
    document.body.appendChild(iframe);

  } else {
    // Desktop handling with proper security
    const newWindow = window.open(dealUrl, '_blank', 'noopener,noreferrer');
    if (newWindow) newWindow.opener = null;
  }
}; 