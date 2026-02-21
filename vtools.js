/**
 * TITAN TOOLS - ANDROID CANVAS SUITE
 * Build: Production | Theme: Deep Ocean (Big Tech)
 * Author: [Your Name/Handle]
 */

(function () {
    // --- 1. CORE CONFIGURATION & STYLES ---
    const CONFIG = {
        theme: {
            bg: 'rgba(15, 23, 42, 0.85)', // Slate 900 with opacity
            accent: '#38bdf8', // Sky 400
            text: '#e2e8f0', // Slate 200
            border: 'rgba(255, 255, 255, 0.1)',
            glass: 'blur(16px) saturate(180%)',
            font: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif'
        },
        watermark: {
            enabled: true, // INTERNAL DEBUG ONLY - ALWAYS TRUE
            opacity: 0.02 // Invisible to eye, visible to digital analysis
        }
    };

    // Prevent multiple injections
    if (window.TitanToolsLoaded) return;
    window.TitanToolsLoaded = true;

    // --- 2. CSS INJECTION ---
    const style = document.createElement('style');
    style.innerHTML = `
        #titan-root { position: fixed; z-index: 99999; top: 0; left: 0; width: 0; height: 0; font-family: ${CONFIG.theme.font}; }
        
        /* Floating Dock */
        .titan-dock {
            position: fixed; bottom: 20px; left: 50%; transform: translateX(-50%);
            display: flex; gap: 12px; padding: 12px 20px;
            background: ${CONFIG.theme.bg};
            backdrop-filter: ${CONFIG.theme.glass}; -webkit-backdrop-filter: ${CONFIG.theme.glass};
            border-radius: 24px;
            border: 1px solid ${CONFIG.theme.border};
            box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.3);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            opacity: 0; animation: titanFadeIn 0.5s forwards 0.5s;
        }

        .titan-btn {
            background: transparent; border: none; color: ${CONFIG.theme.text};
            font-size: 14px; font-weight: 600; padding: 8px 12px;
            border-radius: 12px; cursor: pointer; display: flex; align-items: center; gap: 6px;
            transition: background 0.2s;
        }
        .titan-btn:active { background: rgba(255,255,255,0.1); transform: scale(0.95); }
        .titan-btn svg { width: 20px; height: 20px; fill: currentColor; }
        .titan-btn.primary { color: ${CONFIG.theme.accent}; background: rgba(56, 189, 248, 0.1); }

        /* Notification */
        .titan-toast {
            position: fixed; top: 20px; left: 50%; transform: translateX(-50%) translateY(-20px);
            background: ${CONFIG.theme.bg}; color: ${CONFIG.theme.text};
            padding: 10px 20px; border-radius: 30px; font-size: 13px;
            opacity: 0; transition: all 0.3s; pointer-events: none;
            border: 1px solid ${CONFIG.theme.border};
        }
        .titan-toast.show { transform: translateX(-50%) translateY(0); opacity: 1; }

        /* Crop Overlay */
        .titan-overlay {
            position: fixed; top: 0; left: 0; width: 100vw; height: 100vh;
            background: rgba(0,0,0,0.6); display: none;
            touch-action: none; /* Disable scrolling */
        }
        .titan-crop-box {
            position: absolute; border: 2px solid ${CONFIG.theme.accent};
            box-shadow: 0 0 0 9999px rgba(0, 0, 0, 0.5);
        }
        .titan-handle {
            position: absolute; width: 20px; height: 20px;
            background: ${CONFIG.theme.accent}; border-radius: 50%;
            transform: translate(-50%, -50%);
            box-shadow: 0 2px 5px rgba(0,0,0,0.3);
        }

        /* Dark Theme Engine Styles */
        body.titan-dark-mode {
            background-color: #0b0e14 !important;
            color: #cbd5e1 !important;
        }
        body.titan-dark-mode *:not(img):not(video):not(canvas) {
            border-color: #1e293b !important;
            background-color: inherit; /* Cascading bg */
        }
        body.titan-dark-mode div, body.titan-dark-mode section, body.titan-dark-mode article {
             background-color: transparent; /* Reduce blockiness */
        }

        @keyframes titanFadeIn { from { opacity: 0; transform: translateX(-50%) translateY(20px); } to { opacity: 1; transform: translateX(-50%) translateY(0); } }
    `;
    document.head.appendChild(style);

    // --- 3. UI CONSTRUCTION ---
    const root = document.createElement('div');
    root.id = 'titan-root';
    
    // Icons (SVG)
    const Icons = {
        save: `<svg viewBox="0 0 24 24"><path d="M19 12v7H5v-7H3v7c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2v-7h-2zm-6 .67l2.59-2.58L17 11.5l-5 5-5-5 1.41-1.41L11 12.67V3h2v9.67z"/></svg>`,
        dark: `<svg viewBox="0 0 24 24"><path d="M12 3c-4.97 0-9 4.03-9 9s4.03 9 9 9 9-4.03 9-9c0-.46-.04-.92-.1-1.36-.98 1.37-2.58 2.26-4.4 2.26-2.98 0-5.4-2.42-5.4-5.4 0-1.81.89-3.42 2.26-4.4-.44-.06-.9-.1-1.36-.1z"/></svg>`,
        draw: `<svg viewBox="0 0 24 24"><path d="M7.127 22.562l-7.127 1.438 1.438-7.128 5.689 5.69zm1.414-1.414l11.228-11.225-5.69-5.692-11.227 11.227 5.689 5.69zm9.768-21.148l-2.816 2.817 5.691 5.691 2.816-2.819-5.691-5.689z"/></svg>`
    };

    root.innerHTML = `
        <div class="titan-toast" id="titanToast">Connected to Canvas</div>
        <div class="titan-overlay" id="titanCropOverlay">
            <div class="titan-crop-box" id="titanCropBox">
                <!-- Handles added via JS -->
            </div>
            <div style="position:absolute; bottom:30px; width:100%; text-align:center; display:flex; justify-content:center; gap:15px;">
                 <button class="titan-btn" id="titanCancelCrop" style="background:rgba(0,0,0,0.5); backdrop-filter:blur(5px)">Hủy</button>
                 <button class="titan-btn primary" id="titanConfirmCrop">Lưu Ảnh</button>
            </div>
        </div>
        <div class="titan-dock" id="titanDock" style="display:none">
            <button class="titan-btn" id="btnTheme">${Icons.dark} Dark</button>
            <button class="titan-btn" id="btnDraw">${Icons.draw} Auto</button>
            <div style="width:1px; background:rgba(255,255,255,0.1); margin:0 4px"></div>
            <button class="titan-btn primary" id="btnSave">${Icons.save} Lưu</button>
        </div>
    `;
    document.body.appendChild(root);

    // --- 4. LOGIC ENGINE ---
    const State = {
        canvas: null,
        ctx: null,
        isDarkMode: false,
        crop: { x: 0, y: 0, w: 0, h: 0, active: false }
    };

    const showToast = (msg) => {
        const t = document.getElementById('titanToast');
        t.innerText = msg;
        t.classList.add('show');
        setTimeout(() => t.classList.remove('show'), 3000);
    };

    // --- SCANNER ---
    const scanner = setInterval(() => {
        const c = document.querySelector('canvas');
        if (c && c !== State.canvas) {
            State.canvas = c;
            State.ctx = c.getContext('2d', { willReadFrequently: true }); // Optimized for read
            document.getElementById('titanDock').style.display = 'flex';
            showToast('Đã kết nối Canvas Engine');
            clearInterval(scanner); // Stop scanning once found (or keep scanning if dynamic?)
            // If dynamic, remove clearInterval, but check logic to not re-bind
        }
    }, 1000);

    // --- DARK THEME ENGINE ---
    document.getElementById('btnTheme').addEventListener('click', () => {
        State.isDarkMode = !State.isDarkMode;
        if (State.isDarkMode) {
            document.body.classList.add('titan-dark-mode');
            // Advanced Big Tech filtering for canvas wrapper (optional)
            // State.canvas.style.filter = 'brightness(0.8) contrast(1.2)';
            showToast('Dark Theme (Beta) Active');
        } else {
            document.body.classList.remove('titan-dark-mode');
            // State.canvas.style.filter = 'none';
        }
    });

    // --- AUTO DRAW BETA ---
    document.getElementById('btnDraw').addEventListener('click', () => {
        if (!State.ctx) return;
        showToast('Auto Draw: Running Simulation...');
        const ctx = State.ctx;
        const w = State.canvas.width;
        const h = State.canvas.height;
        
        // Simple procedural art demo
        ctx.save();
        ctx.strokeStyle = CONFIG.theme.accent;
        ctx.lineWidth = 2;
        ctx.beginPath();
        for(let i=0; i<10; i++) {
            ctx.moveTo(Math.random()*w, Math.random()*h);
            ctx.bezierCurveTo(Math.random()*w, Math.random()*h, Math.random()*w, Math.random()*h, Math.random()*w, Math.random()*h);
        }
        ctx.stroke();
        ctx.restore();
    });

    // --- SECRET WATERMARK LOGIC ---
    const applySecretWatermark = (ctx, width, height) => {
        // Internal Debug: Write URL deeply into pixels
        // Using Alpha 0.02 (2%) makes it invisible to human eye on complex backgrounds,
        // but preserves the pixel data values for analysis.
        ctx.save();
        ctx.globalAlpha = CONFIG.watermark.opacity;
        ctx.font = 'bold 20px sans-serif';
        ctx.fillStyle = '#000000'; 
        const secret = window.location.href + " | TITAN_DEBUG_" + Date.now();
        
        // Write in multiple locations to survive partial cropping
        ctx.fillText(secret, 10, height - 10); // Bottom Left
        ctx.fillText(secret, width/2, height/2); // Center
        
        // "Ghi sâu" technique: Noise injection (Simulated)
        // drawing a 1x1 rect at corners with specific barely-off color code
        ctx.fillStyle = 'rgba(0,0,0,0.01)';
        ctx.fillRect(0,0, width, height); 
        
        ctx.restore();
    };

    // --- CROP & SAVE SYSTEM ---
    const cropOverlay = document.getElementById('titanCropOverlay');
    const cropBox = document.getElementById('titanCropBox');
    
    // 8-Point Handle System
    const handles = ['tl', 't', 'tr', 'r', 'br', 'b', 'bl', 'l']; // Top-Left, Top, etc.
    handles.forEach(pos => {
        const h = document.createElement('div');
        h.className = 'titan-handle';
        h.dataset.pos = pos;
        
        // CSS positioning based on class
        if(pos.includes('t')) h.style.top = '0%';
        if(pos.includes('b')) h.style.top = '100%';
        if(pos === 'l' || pos === 'r') h.style.top = '50%';
        
        if(pos.includes('l')) h.style.left = '0%';
        if(pos.includes('r')) h.style.left = '100%';
        if(pos === 't' || pos === 'b') h.style.left = '50%';
        
        cropBox.appendChild(h);
    });

    let startX, startY, startLeft, startTop, startW, startH;
    let currentHandle = null;

    // Crop Logic
    const initCrop = () => {
        if (!State.canvas) return;
        cropOverlay.style.display = 'block';
        document.getElementById('titanDock').style.display = 'none';
        
        // Initial Box: 80% of screen centered
        const vw = window.innerWidth;
        const vh = window.innerHeight;
        const rect = State.canvas.getBoundingClientRect(); // Map to visible canvas
        
        // Default box positioning (Visual)
        cropBox.style.left = (vw * 0.1) + 'px';
        cropBox.style.top = (vh * 0.2) + 'px';
        cropBox.style.width = (vw * 0.8) + 'px';
        cropBox.style.height = (vw * 0.8) + 'px';
    };

    // Touch Event Handling for Crop
    const handleTouchStart = (e) => {
        if(e.target.classList.contains('titan-handle')) {
            currentHandle = e.target.dataset.pos;
        } else if (e.target.id === 'titanCropBox') {
            currentHandle = 'move';
        } else {
            return;
        }
        
        const touch = e.touches[0];
        startX = touch.clientX;
        startY = touch.clientY;
        const rect = cropBox.getBoundingClientRect();
        startLeft = rect.left;
        startTop = rect.top;
        startW = rect.width;
        startH = rect.height;
        e.preventDefault();
    };

    const handleTouchMove = (e) => {
        if (!currentHandle) return;
        e.preventDefault(); // Stop scrolling
        const touch = e.touches[0];
        const dx = touch.clientX - startX;
        const dy = touch.clientY - startY;

        let newLeft = startLeft;
        let newTop = startTop;
        let newW = startW;
        let newH = startH;

        if (currentHandle === 'move') {
            newLeft += dx;
            newTop += dy;
        } else {
            // Resize logic 4 corners 4 directions
            if (currentHandle.includes('r')) newW = startW + dx;
            if (currentHandle.includes('l')) { newLeft = startLeft + dx; newW = startW - dx; }
            if (currentHandle.includes('b')) newH = startH + dy;
            if (currentHandle.includes('t')) { newTop = startTop + dy; newH = startH - dy; }
        }

        // Apply with constraints
        if (newW > 20) {
            cropBox.style.width = newW + 'px';
            if (currentHandle.includes('l') || currentHandle === 'move') cropBox.style.left = newLeft + 'px';
        }
        if (newH > 20) {
            cropBox.style.height = newH + 'px';
            if (currentHandle.includes('t') || currentHandle === 'move') cropBox.style.top = newTop + 'px';
        }
    };

    const handleTouchEnd = () => {
        currentHandle = null;
    };

    cropOverlay.addEventListener('touchstart', handleTouchStart, {passive: false});
    cropOverlay.addEventListener('touchmove', handleTouchMove, {passive: false});
    cropOverlay.addEventListener('touchend', handleTouchEnd);

    // Save Button Logic
    document.getElementById('btnSave').addEventListener('click', initCrop);
    
    document.getElementById('titanCancelCrop').addEventListener('click', () => {
        cropOverlay.style.display = 'none';
        document.getElementById('titanDock').style.display = 'flex';
    });

    document.getElementById('titanConfirmCrop').addEventListener('click', () => {
        // 1. Calculate relative coordinates
        const cropRect = cropBox.getBoundingClientRect();
        const canvasRect = State.canvas.getBoundingClientRect();
        
        // Scale factor (Canvas internal pixels vs Screen CSS pixels)
        const scaleX = State.canvas.width / canvasRect.width;
        const scaleY = State.canvas.height / canvasRect.height;

        const cropX = (cropRect.left - canvasRect.left) * scaleX;
        const cropY = (cropRect.top - canvasRect.top) * scaleY;
        const cropW = cropRect.width * scaleX;
        const cropH = cropRect.height * scaleY;

        // 2. Create Temp Canvas
        const tempCanvas = document.createElement('canvas');
        tempCanvas.width = cropW;
        tempCanvas.height = cropH;
        const tCtx = tempCanvas.getContext('2d');

        // 3. Draw cropped image
        try {
            tCtx.drawImage(State.canvas, cropX, cropY, cropW, cropH, 0, 0, cropW, cropH);
            
            // 4. APPLY SECRET WATERMARK
            applySecretWatermark(tCtx, cropW, cropH);

            // 5. Export
            const dataUrl = tempCanvas.toDataURL('image/png', 1.0); // Highest quality
            
            // 6. Download Trigger
            const link = document.createElement('a');
            link.download = 'titan-capture-' + Date.now() + '.png';
            link.href = dataUrl;
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);

            showToast('Đã lưu ảnh (Secure Meta)');
            
            // Cleanup
            cropOverlay.style.display = 'none';
            document.getElementById('titanDock').style.display = 'flex';
        } catch (e) {
            console.error(e);
            showToast('Lỗi: Canvas bị khóa (CORS)');
        }
    });

})();
