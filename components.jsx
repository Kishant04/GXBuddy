// GXBuddy — shared components

const COLORS = {
  bg: '#08001A',
  bg2: '#100330',
  bg3: '#1A0744',
  violet: '#8B3FFF',
  violetDeep: '#5C12CC',
  pink: '#FF3D7E',
  pinkDeep: '#C42558',
  green: '#0F6E56',
  greenLight: '#22C796',
  orange: '#F59E0B',
  red: '#EF4444',
  celebration: '#A855F7',
  gold: '#FFD66B',
  text: '#FFFFFF',
  textSoft: 'rgba(255,255,255,0.66)',
  textMute: 'rgba(255,255,255,0.44)',
  border: 'rgba(255,255,255,0.07)',
  borderStrong: 'rgba(255,255,255,0.14)',
  card: 'rgba(255,255,255,0.04)',
  cardHi: 'rgba(255,255,255,0.07)',
};

// ─────────────────────────────────────────────────────────
// GXCard — glassmorphic card
// ─────────────────────────────────────────────────────────
function GXCard({ children, style = {}, glow, padding = 18, onClick, accent }) {
  return (
    <div
      onClick={onClick}
      style={{
        position: 'relative',
        background: 'linear-gradient(180deg, rgba(255,255,255,0.055) 0%, rgba(255,255,255,0.018) 100%)',
        borderRadius: 22,
        padding,
        border: `1px solid ${accent || COLORS.border}`,
        backdropFilter: 'blur(20px) saturate(160%)',
        WebkitBackdropFilter: 'blur(20px) saturate(160%)',
        boxShadow: glow
          ? `0 0 0 1px ${glow}55, 0 12px 40px ${glow}33, 0 1px 0 rgba(255,255,255,0.06) inset, 0 -1px 0 rgba(0,0,0,0.2) inset`
          : '0 10px 28px rgba(0,0,0,0.4), 0 1px 0 rgba(255,255,255,0.06) inset, 0 -1px 0 rgba(0,0,0,0.18) inset',
        cursor: onClick ? 'pointer' : 'default',
        transition: 'transform .2s ease, box-shadow .25s ease',
        ...style,
      }}
    >
      {children}
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// GXButton
// ─────────────────────────────────────────────────────────
function GXButton({ children, onClick, variant = 'primary', size = 'md', icon, style = {}, full }) {
  const sizes = {
    sm: { padding: '9px 14px', fontSize: 13, radius: 11 },
    md: { padding: '14px 18px', fontSize: 14.5, radius: 14 },
    lg: { padding: '17px 22px', fontSize: 16, radius: 16 },
  };
  const s = sizes[size];
  const variants = {
    primary: {
      background: `linear-gradient(180deg, #A45EFF 0%, ${COLORS.violet} 45%, #6A1ED9 100%)`,
      color: '#fff',
      boxShadow: `0 10px 26px ${COLORS.violet}66, 0 1px 0 rgba(255,255,255,0.35) inset, 0 -1px 0 rgba(0,0,0,0.25) inset`,
      border: '1px solid rgba(255,255,255,0.18)',
    },
    pink: {
      background: `linear-gradient(180deg, #FF6B9C 0%, ${COLORS.pink} 50%, ${COLORS.pinkDeep} 100%)`,
      color: '#fff',
      boxShadow: `0 10px 26px ${COLORS.pink}55, 0 1px 0 rgba(255,255,255,0.35) inset, 0 -1px 0 rgba(0,0,0,0.25) inset`,
      border: '1px solid rgba(255,255,255,0.18)',
    },
    ghost: {
      background: 'rgba(255,255,255,0.05)',
      color: '#fff',
      border: '1px solid rgba(255,255,255,0.12)',
      boxShadow: '0 1px 0 rgba(255,255,255,0.06) inset',
    },
    danger: {
      background: 'rgba(239,68,68,0.10)',
      color: '#FF9999',
      border: '1px solid rgba(239,68,68,0.35)',
    },
    success: {
      background: `linear-gradient(180deg, ${COLORS.greenLight}33 0%, ${COLORS.greenLight}1a 100%)`,
      color: '#5DE3B6',
      border: `1px solid ${COLORS.greenLight}55`,
      boxShadow: `0 6px 18px ${COLORS.greenLight}33`,
    },
    soft: {
      background: 'rgba(139,63,255,0.13)',
      color: '#D6BFFF',
      border: '1px solid rgba(139,63,255,0.35)',
    },
  };
  const v = variants[variant];
  return (
    <button
      onClick={onClick}
      style={{
        display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 8,
        padding: s.padding, fontSize: s.fontSize, borderRadius: s.radius,
        fontWeight: 600, cursor: 'pointer', letterSpacing: '-0.01em',
        width: full ? '100%' : undefined, fontFamily: 'inherit',
        transition: 'transform .1s ease, filter .15s ease',
        ...v, ...style,
      }}
      onMouseDown={(e) => (e.currentTarget.style.transform = 'scale(0.97)')}
      onMouseUp={(e) => (e.currentTarget.style.transform = 'scale(1)')}
      onMouseLeave={(e) => (e.currentTarget.style.transform = 'scale(1)')}
    >
      {icon && <span style={{ display: 'inline-flex' }}>{icon}</span>}
      {children}
    </button>
  );
}

// ─────────────────────────────────────────────────────────
// Mascot — original animated buddy character
// ─────────────────────────────────────────────────────────
// GXBot — original retro-console robot mascot
// 4 states: calm / alert / panicked / celebrating
function Mascot({ state = 'calm', size = 120 }) {
  const cfg = {
    calm:        { face: 'happy',   wobble: 'float',  screen: '#5BFF8C', screenDim: '#22C796' },
    alert:       { face: 'worry',   wobble: 'tense',  screen: '#FFB347', screenDim: '#D97706' },
    panicked:    { face: 'shock',   wobble: 'shake',  screen: '#FF6B6B', screenDim: '#DC2626' },
    celebrating: { face: 'stars',   wobble: 'bounce', screen: '#5BFF8C', screenDim: '#22C796' },
  }[state];

  const anim = {
    float:  'mascot-float 3.2s ease-in-out infinite',
    tense:  'mascot-tense 1.6s ease-in-out infinite',
    shake:  'mascot-shake 0.4s ease-in-out infinite',
    bounce: 'mascot-bounce 1.1s ease-in-out infinite',
  }[cfg.wobble];

  return (
    <div style={{ width: size, height: size, position: 'relative', animation: anim }}>
      {/* ambient floor glow */}
      <div style={{
        position: 'absolute', inset: -size*0.15, borderRadius: '50%',
        background: `radial-gradient(circle at 50% 60%, ${cfg.screen}55 0%, transparent 60%)`,
        filter: 'blur(10px)',
        animation: 'mascot-pulse 2.2s ease-in-out infinite',
      }}/>
      <svg viewBox="0 0 220 220" width={size} height={size} style={{ position: 'relative', zIndex: 1, overflow: 'visible' }}>
        <defs>
          <linearGradient id={`body-${state}`} x1="0" y1="0" x2="1" y2="1">
            <stop offset="0%" stopColor="#5C2A8E"/>
            <stop offset="55%" stopColor="#3B156A"/>
            <stop offset="100%" stopColor="#1F0844"/>
          </linearGradient>
          <linearGradient id={`bodySide-${state}`} x1="0" y1="0" x2="1" y2="0">
            <stop offset="0%" stopColor="#3B156A"/>
            <stop offset="100%" stopColor="#1A063C"/>
          </linearGradient>
          <radialGradient id={`screenGrad-${state}`} cx="35%" cy="25%">
            <stop offset="0%" stopColor="#E0FFE8" stopOpacity="0.85"/>
            <stop offset="35%" stopColor={cfg.screen}/>
            <stop offset="100%" stopColor={cfg.screenDim}/>
          </radialGradient>
          <linearGradient id={`limb-${state}`} x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%" stopColor="#7E8B95"/>
            <stop offset="100%" stopColor="#3F4750"/>
          </linearGradient>
        </defs>

        {/* ground shadow */}
        <ellipse cx="110" cy="205" rx="52" ry="6" fill="rgba(0,0,0,0.45)"/>

        {/* legs */}
        <g>
          <rect x="72" y="178" width="14" height="22" rx="4" fill={`url(#limb-${state})`} stroke="#1c1f24" strokeWidth="2"/>
          <ellipse cx="79" cy="200" rx="14" ry="5" fill="#2a2f36" stroke="#1c1f24" strokeWidth="2"/>
          <rect x="134" y="178" width="14" height="22" rx="4" fill={`url(#limb-${state})`} stroke="#1c1f24" strokeWidth="2"/>
          <ellipse cx="141" cy="200" rx="14" ry="5" fill="#2a2f36" stroke="#1c1f24" strokeWidth="2"/>
        </g>

        {/* arms */}
        <g>
          {/* left arm — segmented */}
          <line x1="42" y1="120" x2="22" y2="138" stroke={`url(#limb-${state})`} strokeWidth="7" strokeLinecap="round"/>
          <circle cx="42" cy="120" r="6" fill="#5BFF8C" stroke="#0F6E56" strokeWidth="2"/>
          <circle cx="22" cy="138" r="8" fill="#3a4048" stroke="#1c1f24" strokeWidth="2"/>
          {/* right arm */}
          <line x1="178" y1="120" x2="200" y2={state==='celebrating' ? 70 : 138}
                stroke={`url(#limb-${state})`} strokeWidth="7" strokeLinecap="round"
                style={{ transition: 'all .3s' }}/>
          <circle cx="178" cy="120" r="6" fill="#5BFF8C" stroke="#0F6E56" strokeWidth="2"/>
          <circle cx="200" cy={state==='celebrating' ? 70 : 138} r="8" fill="#3a4048" stroke="#1c1f24" strokeWidth="2"/>
        </g>

        {/* SIDE bevel (right side, BG) */}
        <path d="M170 50 L186 64 L186 174 L170 188 Z"
              fill={`url(#bodySide-${state})`} stroke="#0E0228" strokeWidth="2.5"/>
        {/* Vent holes on side */}
        {[0,1,2,3,4,5].map(i => (
          <circle key={i} cx="178" cy={70 + i*16} r="1.6" fill="#0a0118" opacity="0.9"/>
        ))}

        {/* MAIN BODY (rounded cube front) */}
        <path d="M50 50 Q50 38 62 38 L160 38 Q172 38 172 50 L172 178 Q172 192 158 192 L64 192 Q50 192 50 178 Z"
              fill={`url(#body-${state})`} stroke="#0E0228" strokeWidth="2.5"/>

        {/* highlight on top edge */}
        <path d="M58 44 L162 44" stroke="rgba(255,255,255,0.18)" strokeWidth="2" strokeLinecap="round"/>

        {/* "GX" embossed on left side */}
        <text x="58" y="115" fontSize="10" fontWeight="900" fill="rgba(255,255,255,0.18)"
              transform="rotate(-90 58 115)" letterSpacing="2">GX</text>

        {/* SCREEN bezel */}
        <rect x="64" y="52" width="94" height="74" rx="10"
              fill="#0a0a14" stroke="#FF3D7E" strokeWidth="1.6" opacity="0.85"/>
        {/* screen glow */}
        <rect x="68" y="56" width="86" height="66" rx="7" fill={`url(#screenGrad-${state})`}/>
        {/* scanlines */}
        {[0,1,2,3,4,5].map(i => (
          <rect key={i} x="68" y={56 + i*11} width="86" height="1" fill="rgba(0,0,0,0.07)"/>
        ))}
        {/* CRT shine */}
        <ellipse cx="82" cy="68" rx="14" ry="6" fill="rgba(255,255,255,0.35)"/>

        {/* FACE — drawn on screen */}
        {cfg.face === 'happy' && (
          <g>
            {/* big pixel eyes */}
            <rect x="84" y="78" width="10" height="14" rx="2" fill="#0a2818"/>
            <rect x="128" y="78" width="10" height="14" rx="2" fill="#0a2818"/>
            <circle cx="89" cy="83" r="2.4" fill="#fff"/>
            <circle cx="133" cy="83" r="2.4" fill="#fff"/>
            {/* smile */}
            <path d="M94 102 Q111 116 128 102" stroke="#0a2818" strokeWidth="3.5" fill="none" strokeLinecap="round"/>
          </g>
        )}
        {cfg.face === 'worry' && (
          <g>
            {/* concerned brows */}
            <rect x="80" y="74" width="14" height="3" rx="1.5" fill="#0a2818" transform="rotate(-12 87 75.5)"/>
            <rect x="128" y="74" width="14" height="3" rx="1.5" fill="#0a2818" transform="rotate(12 135 75.5)"/>
            <rect x="84" y="80" width="10" height="14" rx="2" fill="#0a2818"/>
            <rect x="128" y="80" width="10" height="14" rx="2" fill="#0a2818"/>
            {/* flat mouth */}
            <path d="M95 108 Q111 102 127 108" stroke="#0a2818" strokeWidth="3.5" fill="none" strokeLinecap="round"/>
            {/* sweat drop */}
            <path d="M150 78 q-3 6 0 11 q3 -5 0 -11z" fill="#7DD3FC"/>
          </g>
        )}
        {cfg.face === 'shock' && (
          <g>
            {/* X eyes */}
            <path d="M82 80 l12 12 M94 80 l-12 12" stroke="#0a2818" strokeWidth="3.5" strokeLinecap="round"/>
            <path d="M126 80 l12 12 M138 80 l-12 12" stroke="#0a2818" strokeWidth="3.5" strokeLinecap="round"/>
            {/* o-mouth */}
            <ellipse cx="111" cy="108" rx="6" ry="7" fill="#0a2818"/>
            {/* exclamation */}
            <text x="155" y="76" fontSize="20" fontWeight="900" fill="#FF3D7E">!</text>
          </g>
        )}
        {cfg.face === 'stars' && (
          <g>
            {/* star eyes */}
            <path d="M89 78 l2 5 l5 1 l-4 4 l1 5 l-4 -3 l-4 3 l1 -5 l-4 -4 l5 -1 z" fill="#0a2818"/>
            <path d="M133 78 l2 5 l5 1 l-4 4 l1 5 l-4 -3 l-4 3 l1 -5 l-4 -4 l5 -1 z" fill="#0a2818"/>
            {/* big smile */}
            <path d="M90 100 Q111 120 132 100 Q126 110 111 112 Q96 110 90 100 Z" fill="#0a2818"/>
          </g>
        )}

        {/* CONTROL BUTTONS — D-pad (yellow) + A/B (red/cyan) */}
        {/* D-pad cross */}
        <g transform="translate(78 152)">
          <rect x="-3" y="-10" width="6" height="20" rx="1.5" fill="#FFD66B" stroke="#8C6D08" strokeWidth="1.5"/>
          <rect x="-10" y="-3" width="20" height="6" rx="1.5" fill="#FFD66B" stroke="#8C6D08" strokeWidth="1.5"/>
        </g>
        {/* A/B/Start */}
        <circle cx="118" cy="152" r="5" fill="#5BD8FF" stroke="#0E5B7A" strokeWidth="1.5"/>
        <circle cx="135" cy="160" r="5.5" fill="#FF3D7E" stroke="#7A0E37" strokeWidth="1.5"/>
        <circle cx="142" cy="146" r="3.5" fill="#22C796" stroke="#0F4D3A" strokeWidth="1.3"/>
        {/* speaker grille */}
        <g opacity="0.55">
          {[0,1,2].map(i => (
            <line key={i} x1={155 + i*3} y1="148" x2={155 + i*3} y2="166" stroke="#0a0118" strokeWidth="1.2" strokeLinecap="round"/>
          ))}
        </g>

        {/* antenna */}
        <line x1="111" y1="38" x2="111" y2="20" stroke="#3F4750" strokeWidth="3" strokeLinecap="round"/>
        <circle cx="111" cy="16" r="5" fill={cfg.screen} stroke={cfg.screenDim} strokeWidth="1.5">
          <animate attributeName="opacity" values="0.6;1;0.6" dur="1.6s" repeatCount="indefinite"/>
        </circle>
      </svg>

      {/* celebration sparkles */}
      {state === 'celebrating' && (
        <>
          {[
            { t: -4,  l: 4,    d: 0    },
            { t: 14,  l: '88%', d: 0.35 },
            { t: '58%', l: -10, d: 0.7  },
            { t: '66%', l: '92%', d: 1.0 },
            { t: -10, l: '46%', d: 0.18 },
          ].map((s, i) => (
            <div key={i} style={{
              position: 'absolute', top: s.t, left: s.l,
              width: 14, height: 14, animation: `sparkle 1.6s ease-in-out ${s.d}s infinite`,
            }}>
              <svg viewBox="0 0 14 14" width="14" height="14">
                <path d="M7 0 L8 6 L14 7 L8 8 L7 14 L6 8 L0 7 L6 6 Z" fill="#FFD66B"/>
              </svg>
            </div>
          ))}
        </>
      )}
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Progress bar
// ─────────────────────────────────────────────────────────
function ProgressBar({ value, max = 100, color, height = 8, label, sublabel, threshold = true }) {
  const pct = Math.min(100, (value / max) * 100);
  const auto = pct >= 100 ? COLORS.red : pct >= 80 ? COLORS.orange : pct >= 60 ? '#EAB308' : COLORS.greenLight;
  const c = color || auto;
  return (
    <div style={{ width: '100%' }}>
      {(label || sublabel) && (
        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6, fontSize: 13 }}>
          <span style={{ color: COLORS.text, fontWeight: 600 }}>{label}</span>
          <span style={{ color: COLORS.textSoft, fontVariantNumeric: 'tabular-nums' }}>{sublabel}</span>
        </div>
      )}
      <div style={{
        position: 'relative', width: '100%', height, borderRadius: height,
        background: 'rgba(255,255,255,0.06)', overflow: 'hidden',
        border: '1px solid rgba(255,255,255,0.05)',
      }}>
        <div style={{
          width: `${pct}%`, height: '100%',
          background: `linear-gradient(90deg, ${c} 0%, ${c}dd 100%)`,
          borderRadius: height,
          boxShadow: `0 0 12px ${c}88`,
          transition: 'width .6s cubic-bezier(.2,.8,.2,1)',
        }}/>
        {threshold && (
          <>
            <div style={{ position: 'absolute', left: '60%', top: -2, bottom: -2, width: 1, background: 'rgba(255,255,255,0.18)' }}/>
            <div style={{ position: 'absolute', left: '80%', top: -2, bottom: -2, width: 1, background: 'rgba(255,255,255,0.28)' }}/>
          </>
        )}
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Bottom Nav
// ─────────────────────────────────────────────────────────
function BottomNav({ tab, setTab }) {
  const tabs = [
    { id: 'home', label: 'Home', icon: NavIcons.home },
    { id: 'spend', label: 'Spend', icon: NavIcons.spend },
    { id: 'pockets', label: 'Pockets', icon: NavIcons.pocket },
    { id: 'squad', label: 'Squad', icon: NavIcons.squad },
    { id: 'profile', label: 'Profile', icon: NavIcons.profile },
  ];
  return (
    <div style={{
      position: 'absolute', bottom: 0, left: 0, right: 0,
      paddingBottom: 28, paddingTop: 10,
      background: 'linear-gradient(180deg, rgba(12,1,33,0) 0%, rgba(12,1,33,0.85) 35%, rgba(12,1,33,1) 100%)',
      zIndex: 30,
      display: 'flex', justifyContent: 'space-around', alignItems: 'center',
    }}>
      {tabs.map(t => {
        const active = tab === t.id;
        return (
          <button
            key={t.id}
            onClick={() => setTab(t.id)}
            style={{
              background: 'none', border: 'none', cursor: 'pointer',
              display: 'flex', flexDirection: 'column', alignItems: 'center',
              gap: 4, padding: '6px 10px',
              color: active ? COLORS.text : COLORS.textMute,
              transition: 'color .2s',
              fontFamily: 'inherit',
            }}
          >
            <div style={{ position: 'relative' }}>
              {active && <div style={{
                position: 'absolute', inset: -8,
                background: `radial-gradient(circle, ${COLORS.violet}55 0%, transparent 70%)`,
                borderRadius: '50%',
              }}/>}
              <div style={{ position: 'relative', color: active ? COLORS.violet : COLORS.textMute }}>
                {t.icon(active)}
              </div>
            </div>
            <span style={{ fontSize: 10.5, fontWeight: 600, letterSpacing: '-0.01em' }}>{t.label}</span>
          </button>
        );
      })}
    </div>
  );
}

const NavIcons = {
  home: (a) => <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><path d="M3 11.5L12 4l9 7.5V20a1 1 0 01-1 1h-5v-6h-6v6H4a1 1 0 01-1-1v-8.5z" stroke="currentColor" strokeWidth={a?2.2:1.7} fill={a?'currentColor':'none'} strokeLinejoin="round"/></svg>,
  spend: (a) => <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><rect x="3" y="6" width="18" height="14" rx="3" stroke="currentColor" strokeWidth={a?2.2:1.7} fill={a?'currentColor':'none'}/><path d="M3 10h18M7 16h4" stroke={a?'#0C0121':'currentColor'} strokeWidth="1.7" strokeLinecap="round"/></svg>,
  pocket: (a) => <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><path d="M4 7h16v10a3 3 0 01-3 3H7a3 3 0 01-3-3V7z" stroke="currentColor" strokeWidth={a?2.2:1.7} fill={a?'currentColor':'none'}/><path d="M4 7l2-3h12l2 3M9 13a3 3 0 006 0" stroke={a?'#0C0121':'currentColor'} strokeWidth="1.7"/></svg>,
  squad: (a) => <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><circle cx="9" cy="9" r="3.2" stroke="currentColor" strokeWidth={a?2.2:1.7} fill={a?'currentColor':'none'}/><circle cx="17" cy="10" r="2.5" stroke="currentColor" strokeWidth={a?2.2:1.7} fill={a?'currentColor':'none'}/><path d="M3 19c0-3 2.5-5 6-5s6 2 6 5M15 19c0-2 1.5-3.5 3.5-3.5S22 17 22 19" stroke="currentColor" strokeWidth={a?2.2:1.7} strokeLinecap="round" fill="none"/></svg>,
  profile: (a) => <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="8" r="4" stroke="currentColor" strokeWidth={a?2.2:1.7} fill={a?'currentColor':'none'}/><path d="M4 20c0-4 4-6 8-6s8 2 8 6" stroke="currentColor" strokeWidth={a?2.2:1.7} fill={a?'currentColor':'none'} strokeLinecap="round"/></svg>,
};

// ─────────────────────────────────────────────────────────
// Toast
// ─────────────────────────────────────────────────────────
function Toast({ children, visible, accent = COLORS.violet, action, onAction }) {
  return (
    <div style={{
      position: 'absolute', left: 16, right: 16, bottom: 96, zIndex: 80,
      transform: visible ? 'translateY(0)' : 'translateY(40px)',
      opacity: visible ? 1 : 0,
      pointerEvents: visible ? 'auto' : 'none',
      transition: 'transform .35s cubic-bezier(.2,.8,.2,1), opacity .25s',
    }}>
      <div style={{
        background: 'rgba(20,5,55,0.95)', backdropFilter: 'blur(24px)',
        border: `1px solid ${accent}66`,
        borderRadius: 18, padding: '14px 16px',
        display: 'flex', alignItems: 'center', gap: 12,
        boxShadow: `0 16px 40px rgba(0,0,0,0.5), 0 0 0 1px ${accent}33`,
      }}>
        <div style={{
          width: 8, height: 8, borderRadius: '50%', background: accent,
          boxShadow: `0 0 12px ${accent}`,
          flexShrink: 0,
        }}/>
        <div style={{ flex: 1, fontSize: 13.5, color: '#fff', lineHeight: 1.4 }}>{children}</div>
        {action && (
          <button onClick={onAction} style={{
            background: 'rgba(255,255,255,0.08)', color: '#fff',
            border: '1px solid rgba(255,255,255,0.15)',
            padding: '7px 12px', borderRadius: 10,
            fontSize: 12, fontWeight: 600, cursor: 'pointer',
            fontFamily: 'inherit',
          }}>{action}</button>
        )}
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────────
function SectionHeader({ title, action, onAction }) {
  return (
    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 12, marginTop: 4 }}>
      <h2 style={{ fontSize: 17, fontWeight: 700, color: COLORS.text, margin: 0, letterSpacing: '-0.02em' }}>{title}</h2>
      {action && <button onClick={onAction} style={{
        background: 'none', border: 'none', color: COLORS.violet,
        fontSize: 13, fontWeight: 600, cursor: 'pointer', fontFamily: 'inherit',
      }}>{action}</button>}
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Generic merchant icon
// ─────────────────────────────────────────────────────────
function MerchantIcon({ name, color, glyph }) {
  return (
    <div style={{
      width: 42, height: 42, borderRadius: 12,
      background: color,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      flexShrink: 0,
      fontSize: 18, fontWeight: 800, color: '#fff',
      letterSpacing: '-0.02em',
      boxShadow: `0 6px 14px ${color}66`,
    }}>{glyph}</div>
  );
}

Object.assign(window, { COLORS, GXCard, GXButton, Mascot, ProgressBar, BottomNav, Toast, SectionHeader, MerchantIcon, NavIcons });
