// GENERATED FILE - DO NOT MODIFY BY HAND
// Ported 1:1 from static-ui/device-preview/components/mascot
// ignore_for_file: prefer_single_quotes
import 'mascot_model.dart';

class MascotRegistry {
  static const MascotData ash = MascotData(
    id: "ash",
    name: "Ash",
    role: "Kẻ Sinh Tồn",
    tier: "Debt (< 0 ₫)",
    range: "Nợ · dưới 0 ₫",
    min: -999999999999,
    max: -1,
    colorHex: "#718096",
    blobColorHex: "#718096",
    accentHex: "#4a5568",
    personality: "Hay hoảng loạn, cẩn trọng thái quá, theo chủ nghĩa \"thắt lưng buộc bụng\" tuyệt đối.",
    finance: "Mọi khoản chi tiêu đều là mối đe dọa. Ưu tiên số 1 là trả nợ.",
    advice: "Khuyên ngăn mọi khoản chi tiêu không thiết yếu. Thường xuyên cảnh tỉnh bạn.",
    q1: "Khoan đã!! Ly trà sữa này bằng cả 3 bữa mì tôm của chúng ta đấy! Bỏ xuống, bỏ xuống ngay!",
    q2: "Hôm nay bạn chưa quẹt thẻ lần nào! Kỷ lục tuyệt vời, giữ vững nhé!",
    bubble: "Khoan đã!! Ly trà sữa này bằng cả 3 bữa mì tôm đấy!",
    svg: r'''<svg viewBox="0 0 200 240" xmlns="http://www.w3.org/2000/svg">
  <g transform="translate(0, 20)">
    <!-- Body Blob (Dull, sagging shape) -->
    <path d="M 30 90 Q 40 40 100 40 Q 160 40 170 90 Q 180 170 100 160 Q 20 170 30 90 Z" fill="#a0aec0" />
    <!-- Patches and Stitches -->
    <rect x="130" y="110" width="25" height="25" rx="3" fill="#cbd5e0" transform="rotate(15 130 110)" />
    <line x1="125" y1="120" x2="160" y2="125" stroke="#4a5568" stroke-width="2" />
    <line x1="135" y1="110" x2="140" y2="140" stroke="#4a5568" stroke-width="2" />
    <line x1="145" y1="112" x2="150" y2="142" stroke="#4a5568" stroke-width="2" />
    <!-- Bandage on cheek -->
    <rect x="40" y="90" width="20" height="8" fill="#fbd38d" transform="rotate(-20 40 90)" />
    <rect x="45" y="85" width="8" height="20" fill="#fbd38d" transform="rotate(-20 45 85)" />

    <!-- Eyes (Exhausted, dark circles) -->
    <ellipse cx="65" cy="85" rx="16" ry="8" fill="#4a5568" opacity="0.3" />
    <ellipse cx="135" cy="85" rx="16" ry="8" fill="#4a5568" opacity="0.3" />

    <g transform="translate(65, 75)">
      <circle cx="0" cy="0" r="14" fill="#e2e8f0" />
      <!-- Drooping eyelids -->
      <path d="M -15 -5 Q 0 5 15 -5 L 15 -15 L -15 -15 Z" fill="#a0aec0" />
      <circle cx="2" cy="2" r="5" fill="#2d3748" class="pupil" />
    </g>
    <g transform="translate(135, 75)">
      <circle cx="0" cy="0" r="14" fill="#e2e8f0" />
      <path d="M -15 -5 Q 0 5 15 -5 L 15 -15 L -15 -15 Z" fill="#a0aec0" />
      <circle cx="-2" cy="2" r="5" fill="#2d3748" class="pupil" />
    </g>
    <!-- Mouth (Trembling sad line) -->
    <path d="M 88 100 Q 95 95 100 100 T 112 100" fill="none" stroke="#2d3748" stroke-width="3" stroke-linecap="round" />
    <!-- Prop: Spider web & Fly -->
    <path d="M 170 30 L 150 50 M 160 20 L 150 40 M 175 40 L 155 45" stroke="#e2e8f0" stroke-width="1" />
    <circle cx="160" cy="15" r="2" fill="#2d3748" />
  </g>
</svg>''',
  );

  static const MascotData penny = MascotData(
    id: "penny",
    name: "Penny",
    role: "Kế Toán Săn Sale",
    tier: "Struggling (0 – 1M ₫)",
    range: "0 – 1.000.000 ₫",
    min: 0,
    max: 999999,
    colorHex: "#d97706",
    blobColorHex: "#fbd38d",
    accentHex: "#dd6b20",
    personality: "Tỉ mỉ, chi li, nữ hoàng săn mã giảm giá, ám ảnh với việc tối ưu từng nghìn lẻ.",
    finance: "\"Tích tiểu thành đại\", không lãng phí dù chỉ một đồng.",
    advice: "Luôn nhắc nhở về các mã freeship, voucher, và phân tích xem món đồ có thực sự \"đáng tiền\" không.",
    q1: "Đợi đã, nếu áp mã này vào thứ 6 thì rẻ hơn được 15k! Đừng mua vội!",
    q2: "Hôm nay tiết kiệm được 20k tiền xe ôm. Tôi bỏ ngay vào ống heo đây!",
    bubble: "Một đồng cũng là tiền, nhớ săn voucher nhé!",
    svg: r'''<svg viewBox="0 0 200 240" xmlns="http://www.w3.org/2000/svg">
  <g transform="translate(0, 20)">
    <!-- Body Blob -->
    <path d="M 40 80 Q 40 30 100 30 Q 160 30 160 80 Q 170 160 100 160 Q 30 160 40 80 Z" fill="#fefcbf" />
    <!-- Too large sweater collar (looks handed-down) -->
    <path d="M 60 130 Q 100 160 140 130" fill="none" stroke="#ed8936" stroke-width="12" stroke-linecap="round" />

    <!-- Eyes (Hyper-focused, wide open) -->
    <g transform="translate(70, 75)">
      <circle cx="0" cy="0" r="18" fill="#ffffff" class="eye" />
      <circle cx="3" cy="3" r="8" fill="#2d3748" class="pupil" />
      <circle cx="5" cy="1" r="3" fill="#ffffff" class="highlight" />
    </g>
    <g transform="translate(130, 75)">
      <circle cx="0" cy="0" r="18" fill="#ffffff" class="eye" />
      <circle cx="-3" cy="3" r="8" fill="#2d3748" class="pupil" />
      <circle cx="-1" cy="1" r="3" fill="#ffffff" class="highlight" />
    </g>

    <!-- Mouth (Biting lip / nervous concentration) -->
    <path d="M 92 100 Q 100 95 108 100" fill="none" stroke="#2d3748" stroke-width="3" stroke-linecap="round" />
    <rect x="96" y="100" width="8" height="4" rx="2" fill="#fff" stroke="#2d3748" stroke-width="1" />

    <!-- Sweat Drop (Working hard to save) -->
    <path d="M 155 45 Q 160 55 155 60 Q 150 55 155 45 Z" fill="#63b3ed" opacity="0.8" />

    <!-- Prop: Giant Penny clutched tightly -->
    <g transform="translate(100, 140)">
      <!-- Arms wrapping around coin -->
      <circle cx="-25" cy="-5" r="8" fill="#f6ad55" />
      <circle cx="25" cy="-5" r="8" fill="#f6ad55" />
      <!-- Giant Coin -->
      <circle cx="0" cy="0" r="22" fill="#ecc94b" stroke="#d69e2e" stroke-width="4" />
      <text x="0" y="6" font-family="'Outfit', sans-serif" font-weight="900" font-size="18" fill="#b7791f" text-anchor="middle">₫</text>
      <circle cx="-15" cy="10" r="8" fill="#f6ad55" />
      <circle cx="15" cy="10" r="8" fill="#f6ad55" />
    </g>
  </g>
</svg>''',
  );

  static const MascotData sage = MascotData(
    id: "sage",
    name: "Sage",
    role: "Người Làm Vườn Nhẫn Nại",
    tier: "Getting By (1M – 5M ₫)",
    range: "1.000.000 – 5.000.000 ₫",
    min: 1000000,
    max: 4999999,
    colorHex: "#48bb78",
    blobColorHex: "#9ae6b4",
    accentHex: "#38a169",
    personality: "Ấm áp, tích cực, kiên nhẫn. Coi tài chính như một cái cây cần được tưới nước mỗi ngày.",
    finance: "Xây dựng thói quen tốt quan trọng hơn là cắt giảm cực đoan.",
    advice: "Cân bằng giữa tiết kiệm và tự thưởng. Rất thích khen ngợi khi bạn đạt được những cột mốc nhỏ.",
    q1: "Quỹ dự phòng của chúng ta đang nhú mầm rất đẹp rồi. Cuối tuần này mua một cuốn sách tự thưởng nhé!",
    q2: "Chậm mà chắc. Hôm nay bạn tiêu xài rất có kỷ luật đấy.",
    bubble: "Cây tài chính đang lớn lên từng ngày rồi!",
    svg: r'''<svg viewBox="0 0 200 240" xmlns="http://www.w3.org/2000/svg">
  <g transform="translate(0, 20)">
    <!-- Body Blob (Fresh, upright posture) -->
    <path d="M 45 75 Q 45 25 100 25 Q 155 25 155 75 Q 165 155 100 155 Q 35 155 45 75 Z" fill="#e6fffa" />
    <!-- Neat apron/shirt -->
    <path d="M 60 110 L 140 110 L 130 160 L 70 160 Z" fill="#b2f5ea" />

    <!-- Eyes (Bright, hopeful) -->
    <g transform="translate(70, 75)">
      <circle cx="0" cy="0" r="14" fill="#ffffff" class="eye" />
      <circle cx="0" cy="-2" r="7" fill="#2d3748" class="pupil" />
      <path d="M -5 -8 Q 0 -15 5 -8" fill="none" stroke="#fff" stroke-width="3" stroke-linecap="round" />
    </g>
    <g transform="translate(130, 75)">
      <circle cx="0" cy="0" r="14" fill="#ffffff" class="eye" />
      <circle cx="0" cy="-2" r="7" fill="#2d3748" class="pupil" />
      <path d="M -5 -8 Q 0 -15 5 -8" fill="none" stroke="#fff" stroke-width="3" stroke-linecap="round" />
    </g>
    <ellipse cx="50" cy="90" rx="10" ry="6" fill="#ff8a80" opacity="0.4" class="blush" />
    <ellipse cx="150" cy="90" rx="10" ry="6" fill="#ff8a80" opacity="0.4" class="blush" />

    <!-- Mouth (Gentle Smile) -->
    <path d="M 90 95 Q 100 110 110 95" fill="none" stroke="#2d3748" stroke-width="4" stroke-linecap="round" />

    <!-- Prop: A sprouting plant in a little pot -->
    <g transform="translate(100, 135)">
      <!-- Pot -->
      <path d="M -15 15 L 15 15 L 10 -5 L -10 -5 Z" fill="#ed8936" />
      <!-- Soil -->
      <ellipse cx="0" cy="-5" rx="10" ry="3" fill="#744210" />
      <!-- Leaves -->
      <path d="M 0 -5 Q -15 -20 -5 -25 Q 5 -15 0 -5" fill="#48bb78" />
      <path d="M 0 -5 Q 15 -15 20 -5 Q 10 5 0 -5" fill="#38a169" />
      <!-- Hands holding the pot -->
      <circle cx="-15" cy="5" r="7" fill="#81e6d9" />
      <circle cx="15" cy="5" r="7" fill="#81e6d9" />
    </g>
  </g>
</svg>''',
  );

  static const MascotData nora = MascotData(
    id: "nora",
    name: "Nora",
    role: "Huấn Luyện Viên Đời Sống",
    tier: "Comfortable (5M – 20M ₫)",
    range: "5.000.000 – 20.000.000 ₫",
    min: 5000000,
    max: 19999999,
    colorHex: "#0072d5",
    blobColorHex: "#0072d5",
    accentHex: "#0055a9",
    personality: "Điềm tĩnh, logic, chuyên nghiệp nhưng vẫn rất thân thiện (chuẩn AI hiện đại).",
    finance: "Quản lý theo quy tắc rõ ràng (ví dụ: 50/30/20): chất lượng cuộc sống và tài chính đi đôi với nhau.",
    advice: "Phân tích dữ liệu, đưa ra lời khuyên dựa trên biểu đồ. Cho phép bạn tiêu tiền nhưng phải nằm trong kế hoạch.",
    q1: "Khoản chi 500k này vẫn nằm trong quỹ \"Giải trí\" của tháng. Bạn hoàn toàn có thể chi trả mà không ảnh hưởng mục tiêu chung.",
    q2: "Có vẻ dạo này bạn hơi tốn tiền ăn ngoài. Có muốn tôi lên kế hoạch nấu ăn tuần tới không?",
    bubble: "Có tôi hỗ trợ bạn, yên tâm nhé ✦",
    svg: r'''<svg viewBox="0 0 200 240" xmlns="http://www.w3.org/2000/svg">
  <g transform="translate(0, 20)">
    <!-- Spark Background Aura -->
    <circle cx="100" cy="90" r="80" fill="#ebf4ff" opacity="0.6" />
    <!-- Body Blob (Perfectly symmetrical, futuristic) -->
    <path d="M 40 80 Q 40 30 100 30 Q 160 30 160 80 Q 165 160 100 160 Q 35 160 40 80 Z" fill="#0072d5" />

    <!-- Face Plate (Screen aesthetic) -->
    <rect x="50" y="50" width="100" height="70" rx="35" fill="#ffffff" stroke="#f7fcff" stroke-width="4" />

    <!-- Eyes (Digital/Calm) -->
    <g transform="translate(75, 80)">
      <circle cx="0" cy="0" r="10" fill="#0055a9" />
      <circle cx="2" cy="-2" r="3" fill="#fff" />
    </g>
    <g transform="translate(125, 80)">
      <circle cx="0" cy="0" r="10" fill="#0055a9" />
      <circle cx="2" cy="-2" r="3" fill="#fff" />
    </g>

    <!-- Mouth (Perfect smile arc) -->
    <path d="M 92 98 Q 100 104 108 98" fill="none" stroke="#0055a9" stroke-width="3" stroke-linecap="round" />

    <!-- Prop: Finora Spark ✦ (Floating) -->
    <g transform="translate(145, 30)">
      <path d="M 0 10 Q -10 10 -10 20 Q -10 10 -20 10 Q -10 10 -10 0 Q -10 10 0 10 Z" fill="#f6e05e" />
    </g>
    <g transform="translate(57, 120)">
      <path d="M 0 10 Q -10 10 -10 20 Q -10 10 -20 10 Q -10 10 -10 0 Q -10 10 0 10 Z" fill="#f6e05e" transform="scale(0.6)" />
    </g>

    <!-- Clean UI Collar -->
    <path d="M 70 120 L 130 120 L 120 140 L 80 140 Z" fill="#fff" opacity="0.3" />

    <!-- Prop: Bank Card held in the middle (like Penny holds her coin) -->
    <g transform="translate(100, 140)">
      <!-- Hands wrapping around the card -->
      <circle cx="-24" cy="-4" r="9" fill="#d9e6ff" />
      <circle cx="24" cy="-4" r="9" fill="#d9e6ff" />
      <!-- Bank card -->
      <g transform="translate(0, 0) scale(0.72)">
        <rect x="-24" y="-16" width="48" height="32" rx="6" fill="#ffffff" stroke="#b8c2d4" stroke-width="4" />
        <rect x="-24" y="-16" width="48" height="13" rx="6" fill="#0072d5" />
        <rect x="-24" y="-3" width="48" height="4" fill="#c9d3e2" />
        <rect x="-16" y="-9" width="10" height="8" rx="2" fill="#f5c04a" />
        <circle cx="8" cy="-7" r="1.6" fill="#8892a6" />
        <circle cx="15" cy="-7" r="1.6" fill="#8892a6" />
        <circle cx="22" cy="-7" r="1.6" fill="#8892a6" />
      </g>
    </g>
  </g>
</svg>''',
  );

  static const MascotData jade = MascotData(
    id: "jade",
    name: "Jade",
    role: "Chiến Lược Gia Đầu Tư",
    tier: "Wealthy (20M – 100M ₫)",
    range: "20.000.000 – 100.000.000 ₫",
    min: 20000000,
    max: 99999999,
    colorHex: "#059669",
    blobColorHex: "#68d391",
    accentHex: "#276749",
    personality: "Sắc sảo, thực tế, ghét việc tiền nằm im một chỗ.",
    finance: "Tiền là công cụ: dùng tiền đẻ ra tiền, dùng tiền để mua lại thời gian.",
    advice: "Thường xuyên gợi ý các quỹ đầu tư, gửi tiết kiệm sinh lời. Khuyến khích chi tiền cho các dịch vụ tiện ích giúp tiết kiệm thời gian.",
    q1: "Số tiền này để không trong thẻ ATM làm gì? Chuyển ngay 10 triệu vào quỹ tích lũy sinh lời đi.",
    q2: "Thời gian của bạn kiếm được nhiều tiền hơn thế. Hãy ủy thác các việc vụn vặt!",
    bubble: "Tiền nên tự sinh lời, đúng chứ?",
    svg: r'''<svg viewBox="0 0 200 240" xmlns="http://www.w3.org/2000/svg">
  <g transform="translate(0, 20)">
    <!-- Body Blob -->
    <path d="M 40 80 Q 40 30 100 30 Q 160 30 160 80 Q 170 160 100 160 Q 30 160 40 80 Z" fill="#38a169" />

    <!-- Sharp Blazer -->
    <path d="M 40 100 L 100 150 L 160 100 L 170 160 L 30 160 Z" fill="#22543d" />
    <!-- Inner shirt -->
    <path d="M 80 100 L 100 140 L 120 100 Z" fill="#fff" />

    <!-- Smart Glasses (Thick dark frames) -->
    <rect x="55" y="65" width="40" height="28" rx="6" fill="#fff" opacity="0.9" stroke="#1a202c" stroke-width="4" />
    <rect x="105" y="65" width="40" height="28" rx="6" fill="#fff" opacity="0.9" stroke="#1a202c" stroke-width="4" />
    <line x1="95" y1="79" x2="105" y2="79" stroke="#1a202c" stroke-width="4" />

    <!-- Eyes (Confident, looking up/forward) -->
    <g transform="translate(75, 79)">
      <circle cx="0" cy="0" r="6" fill="#2d3748" />
      <circle cx="2" cy="-2" r="2" fill="#fff" />
    </g>
    <g transform="translate(125, 79)">
      <circle cx="0" cy="0" r="6" fill="#2d3748" />
      <circle cx="2" cy="-2" r="2" fill="#fff" />
    </g>

    <!-- Mouth (Confident smirk) -->
    <path d="M 90 105 Q 100 110 112 100" fill="none" stroke="#2d3748" stroke-width="3" stroke-linecap="round" />

    <!-- Prop: Upward Chart Tablet -->
    <g transform="translate(110, 110) rotate(10)">
      <rect x="0" y="0" width="40" height="50" rx="4" fill="#f7fafc" stroke="#2d3748" stroke-width="2" />
      <!-- Green upward line -->
      <path d="M 5 40 L 15 30 L 25 35 L 35 15 L 35 45 Z" fill="#48bb78" opacity="0.5" />
      <path d="M 5 40 L 15 30 L 25 35 L 35 15" fill="none" stroke="#2f855a" stroke-width="3" stroke-linejoin="round" />
      <!-- Hand holding it -->
      <circle cx="0" cy="40" r="6" fill="#48bb78" />
    </g>
  </g>
</svg>''',
  );

  static const MascotData ruby = MascotData(
    id: "ruby",
    name: "Ruby",
    role: "Quý Cô Hưởng Thụ",
    tier: "Rich (100M – 500M ₫)",
    range: "100.000.000 – 500.000.000 ₫",
    min: 100000000,
    max: 499999999,
    colorHex: "#ec4899",
    blobColorHex: "#feb2b2",
    accentHex: "#9b2c2c",
    personality: "Sang chảnh, tinh tế, thích đồ \"Auth\" và trải nghiệm cao cấp.",
    finance: "Cuộc đời quá ngắn để dùng đồ rẻ tiền. Đầu tư vào bản thân và trải nghiệm là khoản đầu tư tốt nhất.",
    advice: "Cổ vũ bạn chọn những món đồ chất lượng cao, tối ưu hóa phong cách sống. Chê bai những khoản tiết kiệm vụn vặt.",
    q1: "Quẹt thẻ mua hẳn đồ Auth đi cưng, bạn dư sức mà. Chất lượng mới là mãi mãi!",
    q2: "Kỳ nghỉ này hãy book hạng thương gia nhé. Chúng ta không có thời gian cho việc mệt mỏi đâu.",
    bubble: "Tiền không còn là nỗi lo nữa, hãy tận hưởng!",
    svg: r'''<svg viewBox="0 0 200 240" xmlns="http://www.w3.org/2000/svg">
  <g transform="translate(0, 20)">
    <!-- Body Blob -->
    <path d="M 35 80 Q 35 30 100 30 Q 165 30 165 80 Q 175 160 100 160 Q 25 160 35 80 Z" fill="#9b2c2c" />

    <!-- Fur Cape / Boa -->
    <path d="M 20 110 Q 50 80 100 100 Q 150 80 180 110 Q 170 140 100 130 Q 30 140 20 110 Z" fill="#fff5f5" />

    <!-- Large Gold Crown -->
    <path d="M 70 10 L 80 -15 L 100 5 L 120 -15 L 130 10 Z" fill="#ecc94b" />
    <!-- Jewels on Crown -->
    <circle cx="80" cy="-5" r="4" fill="#fc8181" />
    <circle cx="100" cy="5" r="5" fill="#fc8181" />
    <circle cx="120" cy="-5" r="4" fill="#fc8181" />

    <!-- Eyes (Sultry / Elegant) -->
    <g transform="translate(70, 70)">
      <circle cx="0" cy="0" r="14" fill="#ffffff" class="eye" />
      <path d="M -15 -5 Q 0 -10 15 -5 L 15 -15 L -15 -15 Z" fill="#742a2a" />
      <path d="M 12 -8 L 20 -12" stroke="#742a2a" stroke-width="3" stroke-linecap="round" />
      <circle cx="0" cy="3" r="6" fill="#2d3748" class="pupil" />
      <circle cx="2" cy="0" r="2" fill="#ffffff" class="highlight" />
    </g>
    <g transform="translate(130, 70)">
      <circle cx="0" cy="0" r="14" fill="#ffffff" class="eye" />
      <path d="M -15 -5 Q 0 -10 15 -5 L 15 -15 L -15 -15 Z" fill="#742a2a" />
      <path d="M -12 -8 L -20 -12" stroke="#742a2a" stroke-width="3" stroke-linecap="round" />
      <circle cx="0" cy="3" r="6" fill="#2d3748" class="pupil" />
      <circle cx="2" cy="0" r="2" fill="#ffffff" class="highlight" />
    </g>

    <!-- Blushes -->
    <ellipse cx="50" cy="85" rx="10" ry="5" fill="#f56565" opacity="0.6" />
    <ellipse cx="150" cy="85" rx="10" ry="5" fill="#f56565" opacity="0.6" />

    <!-- Mouth (Sophisticated smirk, red lips) -->
    <path d="M 90 95 Q 100 102 112 90" fill="none" stroke="#742a2a" stroke-width="4" stroke-linecap="round" />
    <path d="M 98 96 Q 100 93 102 96" fill="none" stroke="#f56565" stroke-width="3" stroke-linecap="round" />

    <!-- Prop: Giant Diamond Necklace -->
    <path d="M 80 130 L 100 150 L 120 130" fill="none" stroke="#ecc94b" stroke-width="4" />
    <polygon points="90,150 110,150 100,170" fill="#63b3ed" />
    <polygon points="90,150 110,150 100,150" fill="#90cdf4" />
  </g>
</svg>''',
  );

  static const MascotData bellingham = MascotData(
    id: "bellingham",
    name: "Bellingham",
    role: "Chủ Tịch Tài Phiệt",
    tier: "Tycoon (500M+ ₫)",
    range: "≥ 500.000.000 ₫",
    min: 500000000,
    max: 999999999999,
    colorHex: "#b7791f",
    blobColorHex: "#ecc94b",
    accentHex: "#1a202c",
    personality: "Tự mãn, vĩ mô, suy nghĩ kiểu \"tỷ phú\".",
    finance: "Tiền lẻ không quan trọng, đa dạng hóa danh mục đầu tư mới là chân ái. Tiền là điểm số của một trò chơi.",
    advice: "Bỏ qua hoàn toàn các phân tích chi tiêu lặt vặt. Luôn hướng bạn tới việc sở hữu tài sản lớn.",
    q1: "Ly cà phê 100k? Thích thì mua luôn cái chuỗi cà phê đó đi, cấn trừ vào quỹ đầu tư mạo hiểm.",
    q2: "Cảnh báo: Bạn đang có quá nhiều tiền mặt. Chuyển ngay vài trăm triệu vào bất động sản cho tôi!",
    bubble: "Tầm nhìn luôn dài hơi, tiền là điểm số trò chơi.",
    svg: r'''<svg viewBox="0 0 200 240" xmlns="http://www.w3.org/2000/svg">
  <g transform="translate(0, 20)">
    <!-- Floating Gold Bars Background -->
    <g transform="translate(20, 20) rotate(-20)">
      <rect x="0" y="0" width="30" height="15" rx="2" fill="#d69e2e" />
      <rect x="2" y="2" width="26" height="6" rx="1" fill="#ecc94b" />
    </g>
    <g transform="translate(140, 50) rotate(15)">
      <rect x="0" y="0" width="30" height="15" rx="2" fill="#d69e2e" />
      <rect x="2" y="2" width="26" height="6" rx="1" fill="#ecc94b" />
    </g>

    <!-- Body Blob -->
    <path d="M 30 80 Q 30 30 100 30 Q 170 30 170 80 Q 180 160 100 160 Q 20 160 30 80 Z" fill="#1a202c" />

    <!-- Pinstripe Suit details -->
    <line x1="60" y1="120" x2="50" y2="160" stroke="#4a5568" stroke-width="2" />
    <line x1="80" y1="120" x2="70" y2="160" stroke="#4a5568" stroke-width="2" />
    <line x1="120" y1="120" x2="130" y2="160" stroke="#4a5568" stroke-width="2" />
    <line x1="140" y1="120" x2="150" y2="160" stroke="#4a5568" stroke-width="2" />

    <!-- White collar & Gold Tie -->
    <path d="M 80 110 L 100 135 L 120 110 Z" fill="#fff" />
    <path d="M 95 115 L 105 115 L 100 155 Z" fill="#d69e2e" />

    <!-- Solid Gold Top Hat -->
    <path d="M 60 25 L 140 25 L 130 -15 L 70 -15 Z" fill="#d69e2e" />
    <path d="M 50 25 L 150 25 L 150 35 L 50 35 Z" fill="#d69e2e" />
    <rect x="65" y="15" width="70" height="10" fill="#b7791f" />

    <!-- Eyes (Cool, sunglasses) -->
    <g transform="translate(100, 70)">
      <!-- Aviator sunglasses -->
      <path d="M -40 0 Q -20 -10 0 0 Q 20 -10 40 0 L 35 15 Q 20 25 5 10 L 0 5 L -5 10 Q -20 25 -35 15 Z" fill="#2d3748" />
      <!-- Highlight on glasses -->
      <path d="M -30 2 L -15 2" stroke="#fff" stroke-width="2" stroke-linecap="round" opacity="0.5" />
      <path d="M 15 2 L 30 2" stroke="#fff" stroke-width="2" stroke-linecap="round" opacity="0.5" />
      <!-- Bridge frame -->
      <path d="M -45 -2 Q 0 -15 45 -2" fill="none" stroke="#d69e2e" stroke-width="3" />
    </g>

    <!-- Mouth (Very smug) -->
    <path d="M 85 105 Q 100 112 115 98" fill="none" stroke="#fff" stroke-width="3" stroke-linecap="round" />

    <!-- Prop: Gold cane -->
    <line x1="150" y1="90" x2="165" y2="170" stroke="#d69e2e" stroke-width="6" stroke-linecap="round" />
    <circle cx="150" cy="90" r="8" fill="#fff" stroke="#d69e2e" stroke-width="2" />
    <!-- Hand holding cane -->
    <circle cx="150" cy="110" r="7" fill="#1a202c" stroke="#4a5568" stroke-width="1" />
  </g>
</svg>''',
  );

  static const MascotData ronaldo = MascotData(
    id: "ronaldo",
    name: "Ronaldo",
    role: "CR7 Siuuu · Kỷ Lục Gia",
    tier: "Legend (1B+ ₫)",
    range: "≥ 1.000.000.000 ₫",
    min: 1000000000,
    max: 99999999999999,
    colorHex: "#8a1c14",
    blobColorHex: "#feb2b2",
    accentHex: "#1e6f3e",
    personality: "Nhiệt huyết, tự tin vô song, không ngừng phá vỡ mọi kỷ lục tài chính và cuộc sống.",
    finance: "Vô địch tài chính, mỗi khoản đầu tư đều hướng tới đỉnh cao số 1 thế giới.",
    advice: "Không bao giờ thỏa mãn với hiện tại. Luôn đặt mục tiêu cao hơn và Siuuu tới đích!",
    q1: "Siuuuuu! 1 tỷ đó Messi ơi, đếm mỏi tay!",
    q2: "Kỷ lục sinh ra là để phá vỡ. Khối tài sản của bạn cũng vậy!",
    bubble: "Siuuuuu! 1 tỷ đó Messi ơi, đếm mỏi tay!",
    svg: r'''<svg viewBox="0 0 200 240" xmlns="http://www.w3.org/2000/svg">
  <g transform="translate(0, 20)">
    <!-- Thân áo ngoài tổng thể: Màu đỏ bã trầu (Form Nora) -->
    <path d="M 40 80 Q 40 30 100 30 Q 160 30 160 80 Q 165 160 100 160 Q 35 160 40 80 Z" fill="#8a1c14" />

    <!-- Phần xanh lá làm vạt/áo bên dưới -->
    <path d="M 42 110 L 158 110 L 163 155 Q 100 163 37 155 Z" fill="#1e6f3e" />

    <!-- Khuôn mặt (Màu da người) -->
    <rect x="50" y="46" width="100" height="70" rx="35" fill="#f6d0b1" />

    <!-- Mắt (Đen) -->
    <g transform="translate(75, 76)">
      <circle cx="0" cy="0" r="10" fill="#1a202c" />
      <circle cx="2" cy="-2" r="3" fill="#fff" />
    </g>
    <g transform="translate(125, 76)">
      <circle cx="0" cy="0" r="10" fill="#1a202c" />
      <circle cx="2" cy="-2" r="3" fill="#fff" />
    </g>

    <!-- Mồm chu (hình số 3 đứng) -->
    <path d="M 96 84 Q 109 83 106 90 Q 103 92 98 92 Q 103 94 106 97 Q 109 103 96 102" fill="none"
      stroke="#2d3748" stroke-width="3.5" stroke-linecap="round" />

    <!-- Số 7 (Vàng kim) nằm chính giữa phần áo xanh -->
    <text x="100" y="142" font-family="'Outfit', sans-serif" font-weight="900" font-size="28" fill="#f6e05e" text-anchor="middle">7</text>

    <!-- Tay -->
    <g transform="translate(100, 140)">
      <circle cx="-24" cy="-4" r="9" fill="#f6d0b1" />
      <circle cx="24" cy="-4" r="9" fill="#f6d0b1" />
    </g>

    <!-- Chú dê con tròn dễ thương (bên trái) -->
    <g transform="translate(-2, 140) scale(0.55)">
      <path d="M 20 -14 Q 24 -26 13 -28" fill="none" stroke="#b7791f" stroke-width="5" stroke-linecap="round" />
      <path d="M 48 -14 Q 44 -26 55 -28" fill="none" stroke="#b7791f" stroke-width="5" stroke-linecap="round" />
      <ellipse cx="11" cy="6" rx="7" ry="11" fill="#f2d5c0" transform="rotate(18 11 6)" />
      <ellipse cx="57" cy="6" rx="7" ry="11" fill="#f2d5c0" transform="rotate(-18 57 6)" />
      <circle cx="34" cy="14" r="25" fill="#fffaf0" stroke="#e2d9c5" stroke-width="2" />
      <circle cx="24" cy="10" r="3.5" fill="#2d3748" />
      <circle cx="46" cy="10" r="3.5" fill="#2d3748" />
      <ellipse cx="35" cy="22" rx="3.5" ry="2.6" fill="#b7791f" />
      <path d="M 30 27 Q 35 31 41 27" fill="none" stroke="#2d3748" stroke-width="2" stroke-linecap="round" />
      <path d="M 26 33 Q 35 44 44 33 Z" fill="#e6ded0" />
      <circle cx="19" cy="17" r="4" fill="#ffb8b8" opacity="0.75" />
      <circle cx="51" cy="17" r="4" fill="#ffb8b8" opacity="0.75" />
    </g>

    <!-- Cúp World Cup (bên phải) -->
    <g transform="translate(173, 145)">
      <rect x="-6" y="8" width="12" height="4" rx="1.5" fill="#1e6f3e" />
      <rect x="-9" y="12" width="18" height="4" rx="2" fill="#d69e2e" />
      <path d="M -5 8 C -12 2, -10 -8, -3 -2" fill="none" stroke="#f6e05e" stroke-width="2.5" stroke-linecap="round" />
      <path d="M 5 8 C 12 2, 10 -8, 3 -2" fill="none" stroke="#f6e05e" stroke-width="2.5" stroke-linecap="round" />
      <line x1="0" y1="8" x2="0" y2="-2" stroke="#d69e2e" stroke-width="2" />
      <circle cx="0" cy="-9" r="7" fill="#ffd75e" stroke="#d69e2e" stroke-width="1.2" />
      <path d="M -6 -9 A 6 6 0 0 0 6 -9" fill="none" stroke="#d69e2e" stroke-width="0.8" />
      <path d="M 0 -16 L 0 -2" fill="none" stroke="#d69e2e" stroke-width="0.8" />
    </g>
  </g>
</svg>''',
  );

  static const MascotData messi = MascotData(
    id: "messi",
    name: "Messi",
    role: "M10 Goat · Thiên Tài Điềm Đạm",
    tier: "Legend (1B+ ₫)",
    range: "≥ 1.000.000.000 ₫",
    min: 1000000000,
    max: 99999999999999,
    colorHex: "#54a0de",
    blobColorHex: "#bee3f8",
    accentHex: "#1c4e80",
    personality: "Trầm tĩnh, ma thuật, biến những điều phức tạp nhất của tài chính thành nghệ thuật tinh tế.",
    finance: "Quản lý dòng tiền mượt mà như pha đi bóng solo qua 5 hậu vệ.",
    advice: "Giữ vững bình tĩnh, điềm đạm tích lũy và tỏa sáng đúng khoảnh khắc.",
    q1: "Đủ rồi, tôi nghe tiếng 'siuuu' còn ám ảnh hơn báo nợ!",
    q2: "Tài chính vững vàng như cầm cúp vàng World Cup trên tay.",
    bubble: "Đủ rồi, tôi nghe tiếng 'siuuu' còn ám ảnh hơn báo nợ!",
    svg: r'''<svg viewBox="0 0 200 240" xmlns="http://www.w3.org/2000/svg">
  <g transform="translate(0, 20)">
    <!-- Thân áo ngoài tổng thể: Xanh Argentina -->
    <path d="M 40 80 Q 40 30 100 30 Q 160 30 160 80 Q 165 160 100 160 Q 35 160 40 80 Z" fill="#54a0de" />

    <!-- Phần áo trắng + sọc xanh làm vạt/áo bên dưới -->
    <path d="M 42 110 L 158 110 L 163 155 Q 100 163 37 155 Z" fill="#ffffff" />
    <path d="M 42 110 L 158 110 L 160 120 L 40 120 Z" fill="#54a0de" />
    <path d="M 42 132 L 158 132 L 154 142 L 46 142 Z" fill="#54a0de" />

    <!-- Khuôn mặt (Màu da người) -->
    <rect x="50" y="46" width="100" height="70" rx="35" fill="#f6d0b1" />

    <!-- Râu quai nón -->
    <path d="M 58 82 Q 65 118 100 116 Q 135 118 142 82" fill="none" stroke="#3a2b1e" stroke-width="5" stroke-linecap="round" />

    <!-- Mắt (Đen, nhìn sang Ronaldo phía trái) -->
    <g transform="translate(75, 76)">
      <circle cx="0" cy="0" r="10" fill="#1a202c" />
      <circle cx="-3" cy="-2" r="3" fill="#fff" />
    </g>
    <g transform="translate(125, 76)">
      <circle cx="0" cy="0" r="10" fill="#1a202c" />
      <circle cx="-3" cy="-2" r="3" fill="#fff" />
    </g>

    <!-- Mồm buồn (cong ngược) -->
    <path d="M 88 104 Q 100 96 112 104" fill="none" stroke="#2d3748" stroke-width="3.5" stroke-linecap="round" />

    <!-- Số 10 (Xanh đậm) nằm chính giữa phần áo trắng -->
    <text x="100" y="142" font-family="'Outfit', sans-serif" font-weight="900" font-size="28" fill="#1c4e80" text-anchor="middle">10</text>

    <!-- Tay -->
    <g transform="translate(100, 140)">
      <circle cx="-24" cy="-4" r="9" fill="#f6d0b1" />
      <circle cx="24" cy="-4" r="9" fill="#f6d0b1" />
    </g>

    <!-- Quả bóng (bên trái) -->
    <g transform="translate(-2, 150) scale(0.5)">
      <circle cx="0" cy="0" r="22" fill="#ffffff" stroke="#1a202c" stroke-width="2" />
      <polygon points="0,-9 8,-2 5,7 -5,7 -8,-2" fill="#1a202c" />
      <circle cx="-14" cy="8" r="3.5" fill="#1a202c" />
      <circle cx="14" cy="8" r="3.5" fill="#1a202c" />
    </g>

    <!-- Ngôi sao vàng (bên phải) -->
    <g transform="translate(185, 60)">
      <path d="M 0 -10 L 3 -3 L 10 0 L 3 3 L 0 10 L -3 3 L -10 0 L -3 -3 Z" fill="#f6e05e" stroke="#d69e2e" stroke-width="1.5" />
    </g>
  </g>
</svg>''',
  );

  static const MascotData huysun = MascotData(
    id: "huysun",
    name: "Huy Sun",
    role: "Full-stack Dev · Thần Đèn",
    tier: "Special Mascot",
    range: "Infinity Bug-Free",
    min: 0,
    max: 99999999999999,
    colorHex: "#1a2b4c",
    blobColorHex: "#90cdf4",
    accentHex: "#3182ce",
    personality: "Bảnh trai, tóc side part bồng bềnh mượt mà, siêu dễ thương, thông minh và thân thiện.",
    finance: "Tự động hóa mọi dòng tiền, tối ưu thuật toán chi tiêu không một dòng bug.",
    advice: "Code không bug, đời không lo! Luôn refactor và tối ưu tài chính cá nhân.",
    q1: "Code không bug, đời không lo!",
    q2: "Chạy test xanh hết rồi, giờ chill với tách cà phê và xem tài khoản sinh lời thôi!",
    bubble: "Code không bug, đời không lo!",
    svg: r'''<svg viewBox="0 0 200 240" xmlns="http://www.w3.org/2000/svg">
  <g transform="translate(0, 20)">
    <!-- Phần thân áo sơ mi cổ bẻ màu xanh đen -->
    <path d="M 45 110 L 155 110 L 163 158 Q 100 168 37 158 Z" fill="#1a2b4c" />

    <!-- Cổ áo sơ mi trắng bẻ sang 2 bên -->
    <path d="M 70 110 L 100 130 L 130 110 L 115 110 L 100 122 L 85 110 Z" fill="#ffffff" />
    <line x1="100" y1="130" x2="100" y2="155" stroke="#111827" stroke-width="2" />
    <circle cx="100" cy="142" r="2" fill="#d1d5db" />

    <!-- Phần khuôn mặt chiếm trọn ngang (Màu da người) -->
    <path d="M 45 85 Q 40 35 100 35 Q 160 35 155 85 Q 160 135 100 135 Q 40 135 45 85 Z" fill="#f6d0b1" />

    <!-- Má hồng nhẹ nhàng cho dễ thương -->
    <ellipse cx="68" cy="98" rx="8" ry="4" fill="#ff7675" opacity="0.5" />
    <ellipse cx="132" cy="98" rx="8" ry="4" fill="#ff7675" opacity="0.5" />

    <!-- TÓC SIDE PART HÀN QUỐC MƯỢT MÀ, BỒNG BỀNH -->
    <path d="M 46 65 Q 42 28 100 25 Q 158 28 154 65 Z" fill="#1a1a1a" />
    <path d="M 46 65 Q 42 35 72 32 Q 100 28 154 58 Q 145 35 100 32 Q 60 35 46 65 Z" fill="#2d2d2d" />
    <path d="M 72 32 Q 95 42 120 52 Q 105 48 85 40 Z" fill="#1a1a1a" />
    <path d="M 45 55 Q 52 75 62 68 Q 55 52 45 55 Z" fill="#2d2d2d" />

    <!-- Mắt long lanh chibi (to) -->
    <g transform="translate(76, 80)">
      <circle cx="0" cy="0" r="12" fill="#ffffff" />
      <circle cx="1" cy="1" r="6.5" fill="#1a1a1a" />
      <circle cx="3" cy="-1.5" r="2.3" fill="#ffffff" />
    </g>
    <g transform="translate(124, 80)">
      <circle cx="0" cy="0" r="12" fill="#ffffff" />
      <circle cx="1" cy="1" r="6.5" fill="#1a1a1a" />
      <circle cx="3" cy="-1.5" r="2.3" fill="#ffffff" />
    </g>

    <!-- Miệng cười mỉm dễ thương -->
    <path d="M 92 104 Q 100 112 108 104" fill="none" stroke="#2d3748" stroke-width="2.5" stroke-linecap="round" />

    <!-- Tay 2 bên -->
    <circle cx="45" cy="135" r="9" fill="#f6d0b1" />
    <circle cx="155" cy="135" r="9" fill="#f6d0b1" />
  </g>
</svg>''',
  );

  /// Alias for Bellingham
  static const MascotData sterling = bellingham;

  static const Map<String, MascotData> map = {
    "ash": ash,
    "penny": penny,
    "sage": sage,
    "nora": nora,
    "jade": jade,
    "ruby": ruby,
    "bellingham": bellingham,
    "ronaldo": ronaldo,
    "messi": messi,
    "huysun": huysun,
    "sterling": sterling,
  };

  static const List<MascotData> tiers = [
    ash, penny, sage, nora, jade, ruby, bellingham,
  ];

  static const List<MascotData> legends = [
    ronaldo, messi,
  ];

  static const List<MascotData> specials = [
    huysun,
  ];

  static const List<MascotData> all = [
    ash, penny, sage, nora, jade, ruby, bellingham, ronaldo, messi, huysun,
  ];

  /// Retrieve a mascot by id. Defaults to [nora] if not found.
  static MascotData get(String id) {
    final cleanId = id.trim().toLowerCase();
    return map[cleanId] ?? nora;
  }

  /// Automatically resolves the matching Mascot according to account balance/net worth,
  /// identical to the Finora device-preview financial tier system.
  static MascotData resolveByBalance(num balance) {
    final b = balance.toDouble();
    if (b < 0) return ash;
    if (b < 1000000) return penny;
    if (b < 5000000) return sage;
    if (b < 20000000) return nora;
    if (b < 100000000) return jade;
    if (b < 500000000) return ruby;
    return bellingham;
  }
}
