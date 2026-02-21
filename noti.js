(function() {
    // 1. Kiểm tra nếu đã tồn tại thì không inject lại
    if (document.getElementById('vtrip-security-modal')) return;

    // 2. Nhúng Font (Google Fonts: Merriweather & Inter)
    const fontLink = document.createElement('link');
    fontLink.href = 'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Merriweather:wght@300;400;700&display=swap';
    fontLink.rel = 'stylesheet';
    document.head.appendChild(fontLink);

    // 3. Tạo CSS Styles (Scoped để không vỡ giao diện web gốc)
    const style = document.createElement('style');
    style.innerHTML = `
        :root {
            --vt-bg: #F7F5F0;
            --vt-surface: #FFFFFF;
            --vt-text-main: #2D2D2D;
            --vt-text-sub: #666666;
            --vt-accent: #C75D3F; /* Terra Cotta Claude Style */
            --vt-border: #E5E0D8;
            --vt-shadow: 0 20px 40px rgba(0,0,0,0.08), 0 0 0 1px rgba(0,0,0,0.03);
            --vt-font-serif: 'Merriweather', serif;
            --vt-font-sans: 'Inter', sans-serif;
        }

        #vtrip-security-modal {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 999999;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: rgba(247, 245, 240, 0.6); /* Nền mờ đục nhẹ */
            backdrop-filter: blur(12px); /* Hiệu ứng kính mờ cao cấp */
            -webkit-backdrop-filter: blur(12px);
            opacity: 0;
            transition: opacity 0.4s ease;
            font-family: var(--vt-font-sans);
        }

        #vtrip-security-modal.visible {
            opacity: 1;
        }

        .vt-card {
            background: var(--vt-surface);
            width: 100%;
            max-width: 540px;
            padding: 48px;
            border-radius: 24px;
            box-shadow: var(--vt-shadow);
            transform: scale(0.95) translateY(10px);
            transition: transform 0.4s cubic-bezier(0.16, 1, 0.3, 1);
            position: relative;
            overflow: hidden;
        }

        #vtrip-security-modal.visible .vt-card {
            transform: scale(1) translateY(0);
        }

        /* Thanh trang trí trên cùng */
        .vt-bar {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 4px;
            background: var(--vt-accent);
        }

        .vt-header {
            margin-bottom: 32px;
        }

        .vt-brand {
            font-family: var(--vt-font-serif);
            font-size: 14px;
            font-weight: 700;
            letter-spacing: 0.05em;
            text-transform: uppercase;
            color: var(--vt-text-sub);
            margin-bottom: 16px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .vt-brand::before {
            content: '';
            display: block;
            width: 8px;
            height: 8px;
            background: var(--vt-accent);
            border-radius: 50%;
        }

        .vt-title {
            font-family: var(--vt-font-serif);
            font-size: 28px;
            font-weight: 400;
            color: var(--vt-text-main);
            line-height: 1.3;
            letter-spacing: -0.02em;
        }

        .vt-content {
            color: var(--vt-text-sub);
            font-size: 16px;
            line-height: 1.6;
            margin-bottom: 32px;
        }

        .vt-alert-box {
            background-color: #FFF8F6;
            border: 1px solid #F2E8E5;
            padding: 20px;
            border-radius: 12px;
            margin: 24px 0;
        }

        .vt-highlight {
            color: var(--vt-accent);
            font-weight: 600;
            font-family: var(--vt-font-serif);
            padding: 0 4px;
            background: rgba(199, 93, 63, 0.08);
            border-radius: 4px;
        }

        .vt-btn {
            width: 100%;
            padding: 18px;
            background: var(--vt-text-main);
            color: #fff;
            border: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s ease;
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 10px;
        }

        .vt-btn:hover {
            background: #000;
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }

        .vt-footer {
            margin-top: 24px;
            text-align: center;
            font-size: 12px;
            color: #999;
        }

        /* Mobile Responsive */
        @media (max-width: 600px) {
            #vtrip-security-modal {
                align-items: flex-end; /* Đẩy xuống dưới cùng */
            }
            .vt-card {
                max-width: 100%;
                border-bottom-left-radius: 0;
                border-bottom-right-radius: 0;
                padding: 32px 24px;
            }
            .vt-title {
                font-size: 24px;
            }
        }
    `;
    document.head.appendChild(style);

    // 4. Tạo nội dung HTML
    const modalHTML = `
        <div id="vtrip-security-modal">
            <div class="vt-card">
                <div class="vt-bar"></div>
                
                <div class="vt-header">
                    <div class="vt-brand">VTriP AI • System Notice</div>
                    <h1 class="vt-title">Cập nhật Chính sách An toàn & Định danh</h1>
                </div>

                <div class="vt-content">
                    <p>Để đảm bảo tính toàn vẹn của hệ thống, VAI đã kích hoạt giao thức rà soát mới. Chúng tôi yêu cầu sự chú ý đặc biệt đối với các định danh người dùng.</p>
                    
                    <div class="vt-alert-box">
                        <strong style="color: var(--vt-text-main); display:block; margin-bottom:8px;">Cảnh báo nghiêm ngặt:</strong>
                        VAI sẽ hạn chế vĩnh viễn quyền truy cập đối với các tài khoản mang tên <span class="vt-highlight">"Zin"</span>, <span class="vt-highlight">"Lex"</span> hoặc các biến thể liên quan.
                    </div>

                    <p>Hệ thống cũng sẽ tự động quét <strong>danh sách kết bạn (Friend Graph)</strong>. Bất kỳ liên kết nào với các định danh rủi ro nêu trên sẽ dẫn đến việc tài khoản bị gắn cờ an toàn.</p>
                </div>

                <button class="vt-btn" id="vt-confirm-btn">
                    <span>Tôi đã hiểu và Tuân thủ</span>
                </button>

                <div class="vt-footer">
                    VTriP AI Foundation © ${new Date().getFullYear()} <br> Security Protocol ID: VAI-SEC-${Math.floor(Math.random() * 9000) + 1000}
                </div>
            </div>
        </div>
    `;

    // 5. Inject vào Body
    const wrapper = document.createElement('div');
    wrapper.innerHTML = modalHTML;
    document.body.appendChild(wrapper.firstElementChild);

    // 6. Xử lý logic hiển thị & đóng
    const modal = document.getElementById('vtrip-security-modal');
    const btn = document.getElementById('vt-confirm-btn');

    // Trigger animation vào
    setTimeout(() => {
        modal.classList.add('visible');
    }, 10);

    // Xử lý sự kiện click nút
    btn.addEventListener('click', function() {
        btn.innerHTML = 'Đang xác thực hệ thống...';
        btn.style.opacity = '0.8';
        
        setTimeout(() => {
            modal.classList.remove('visible');
            setTimeout(() => {
                modal.remove(); // Xóa khỏi DOM sau khi đóng
                style.remove(); // Xóa style cho sạch
            }, 400);
        }, 800);
    });

})();
