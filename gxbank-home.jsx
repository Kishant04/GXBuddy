// GXBank dashboard host — inspired layout with GXBuddy integrated
const { COLORS } = window;

function GXBankHome({ onOpenBuddy }) {
  const [hidden, setHidden] = React.useState(false);
  return (
    <div style={{
      height: '100%', width: '100%',
      background: `
        radial-gradient(140% 60% at 50% -10%, #5B1A9E 0%, #2A0A5C 35%, #0E0228 65%, #08001A 100%)`,
      position: 'relative', overflow: 'hidden',
      paddingTop: 56,
    }}>
      {/* Top: Total balance */}
      <div style={{ padding: '8px 22px 0', display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, color: 'rgba(255,255,255,0.78)', fontSize: 13, marginBottom: 4 }}>
            Total balance
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
              <path d="M12 2l8 4v6c0 5-3.5 9-8 10-4.5-1-8-5-8-10V6l8-4z" fill="#22C796"/>
              <path d="M8 12l3 3 5-6" stroke="#08001A" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <div style={{ fontSize: 30, fontWeight: 800, color: '#fff', letterSpacing: '-0.03em', fontVariantNumeric: 'tabular-nums' }}>
              {hidden ? '••••••••' : 'RM3,900.00'}
            </div>
            <button onClick={() => setHidden(h => !h)} style={{
              background: 'none', border: 'none', cursor: 'pointer', padding: 2, color: 'rgba(255,255,255,0.7)',
            }}>
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12z" stroke="currentColor" strokeWidth="1.6"/><circle cx="12" cy="12" r="3" stroke="currentColor" strokeWidth="1.6"/></svg>
            </button>
          </div>
          <div style={{ fontSize: 12, color: 'rgba(255,255,255,0.6)', marginTop: 4, display: 'flex', alignItems: 'center', gap: 3 }}>
            Balance info <span style={{ fontSize: 13 }}>›</span>
          </div>
        </div>
        <div style={{ display: 'flex', gap: 14, paddingTop: 4 }}>
          <IconBtn>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="9" stroke="#fff" strokeWidth="1.6"/><path d="M9.5 9a2.5 2.5 0 014.7 1.2c0 1.5-2.2 1.8-2.2 3.3M12 17h.01" stroke="#fff" strokeWidth="1.6" strokeLinecap="round"/></svg>
          </IconBtn>
          <div style={{ position: 'relative' }}>
            <IconBtn>
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M6 8a6 6 0 1112 0v5l1.5 3h-15L6 13V8z" stroke="#fff" strokeWidth="1.6"/><path d="M10 19a2 2 0 004 0" stroke="#fff" strokeWidth="1.6"/></svg>
            </IconBtn>
            <div style={{ position: 'absolute', top: 0, right: 0, width: 8, height: 8, borderRadius: '50%', background: '#FF3D7E', boxShadow: '0 0 8px #FF3D7E' }}/>
          </div>
        </div>
      </div>

      {/* Action card: Add Money / Scan QR / Send Money */}
      <div style={{
        margin: '20px 18px 0', padding: '18px 12px 14px',
        background: 'linear-gradient(180deg, rgba(255,255,255,0.07) 0%, rgba(255,255,255,0.02) 100%)',
        border: '1px solid rgba(255,255,255,0.08)',
        borderRadius: 22,
        display: 'grid', gridTemplateColumns: '1fr 1fr 1fr',
      }}>
        <ActionItem icon={<svg width="20" height="20" viewBox="0 0 24 24"><path d="M12 5v14M5 12h14" stroke="#fff" strokeWidth="2.4" strokeLinecap="round"/></svg>} label="Add Money"/>
        <ActionItem icon={<svg width="20" height="20" viewBox="0 0 24 24" fill="none"><rect x="4" y="4" width="6" height="6" rx="1" stroke="#fff" strokeWidth="2"/><rect x="14" y="4" width="6" height="6" rx="1" stroke="#fff" strokeWidth="2"/><rect x="4" y="14" width="6" height="6" rx="1" stroke="#fff" strokeWidth="2"/><path d="M14 14h2v2M20 14v2M14 18v2h6" stroke="#fff" strokeWidth="2"/></svg>} label="Scan QR"/>
        <ActionItem icon={<svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M3 12l18-7-7 18-3-7-8-4z" stroke="#fff" strokeWidth="2" strokeLinejoin="round"/></svg>} label="Send Money"/>
      </div>

      {/* Your everyday account */}
      <div style={{ padding: '22px 22px 6px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div style={{ fontSize: 15, fontWeight: 700, color: '#fff' }}>Your everyday account</div>
        <div style={{
          width: 30, height: 30, borderRadius: '50%',
          background: 'rgba(255,255,255,0.06)', border: '1px solid rgba(255,255,255,0.1)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <div style={{ width: 6, height: 6, borderRadius: '50%', background: '#FF3D7E', boxShadow: '0 0 6px #FF3D7E' }}/>
        </div>
      </div>

      {/* 3-card row: Main · Saving Pockets · GXBuddy (NEW) */}
      <div style={{
        padding: '0 16px', display: 'grid', gap: 10,
        gridTemplateColumns: '1fr 1fr 1fr',
      }}>
        <AccountCard
          label="Main account"
          amount="RM3,900.00"
          footer={<span style={{ color: 'rgba(255,255,255,0.7)', fontSize: 11 }}>View transactions ›</span>}
        />
        <AccountCard
          label="Saving Pockets"
          amount="RM1,507.38"
          footer={
            <div style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
              {['#A855F7', '#22C796', '#60A5FA', '#FF3D7E'].map((c, i) => (
                <div key={i} style={{
                  width: 18, height: 18, borderRadius: '50%',
                  background: `linear-gradient(135deg, ${c}, ${c}aa)`,
                  border: '2px solid #15052D',
                  marginLeft: i === 0 ? 0 : -8,
                  fontSize: 9, color: '#fff', fontWeight: 700,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}/>
              ))}
              <span style={{ marginLeft: 2, fontSize: 11, color: 'rgba(255,255,255,0.7)', fontWeight: 600 }}>+4</span>
            </div>
          }
        />
        <BuddyCard onClick={onOpenBuddy}/>
      </div>

      {/* For you today */}
      <div style={{ padding: '22px 22px 6px', fontSize: 15, fontWeight: 700, color: '#fff' }}>For you today</div>
      <div style={{ padding: '0 16px' }}>
        <div style={{
          position: 'relative',
          background: 'linear-gradient(180deg, rgba(31,178,135,0.12) 0%, rgba(255,255,255,0.04) 100%)',
          border: '1px solid rgba(34,199,150,0.3)',
          borderRadius: 18, padding: '14px 14px 14px 12px',
          display: 'flex', alignItems: 'center', gap: 12,
        }}>
          <div style={{
            width: 56, height: 56, borderRadius: 14, flexShrink: 0,
            background: 'linear-gradient(135deg, #22C796, #0F6E56)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            boxShadow: '0 6px 16px rgba(34,199,150,0.4)',
          }}>
            <svg width="32" height="32" viewBox="0 0 24 24" fill="none">
              <path d="M3 13c0-4 4-7 9-7s9 3 9 7v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4z" fill="#fff" fillOpacity="0.95"/>
              <text x="12" y="16" textAnchor="middle" fontSize="9" fontWeight="900" fill="#0F6E56">$</text>
            </svg>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 14, fontWeight: 800, color: '#fff' }}>GXBuddy spotted RM2 to save</div>
            <div style={{ fontSize: 11.5, color: 'rgba(255,255,255,0.65)', marginTop: 2 }}>3 food deliveries this week. Round up?</div>
            <button onClick={onOpenBuddy} style={{
              marginTop: 10, padding: '6px 14px', borderRadius: 99,
              background: 'transparent', border: '1px solid rgba(255,255,255,0.3)',
              color: '#fff', fontSize: 11.5, fontWeight: 700, cursor: 'pointer', fontFamily: 'inherit',
            }}>Open GXBuddy ›</button>
          </div>
        </div>
      </div>

      {/* Your insights */}
      <div style={{ padding: '20px 22px 8px', fontSize: 15, fontWeight: 700, color: '#fff' }}>Your insights</div>
      <div style={{ padding: '0 16px 100px', display: 'flex', gap: 10 }}>
        <InsightChip color="#FFB347" label="Spending up 18%"/>
        <InsightChip color="#60A5FA" label="2 bills coming"/>
      </div>

      {/* Bottom nav (GXBank style) */}
      <div style={{
        position: 'absolute', bottom: 0, left: 0, right: 0,
        paddingBottom: 28, paddingTop: 10,
        background: 'linear-gradient(180deg, rgba(8,0,26,0) 0%, #08001A 100%)',
        display: 'flex', justifyContent: 'space-around',
      }}>
        {[
          { l: 'Home', a: true, i: <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><path d="M3 11.5L12 4l9 7.5V20a1 1 0 01-1 1h-5v-6h-6v6H4a1 1 0 01-1-1v-8.5z" stroke="currentColor" strokeWidth="2.2" fill="currentColor"/></svg> },
          { l: 'Rewards', i: <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><rect x="3" y="7" width="18" height="13" rx="2" stroke="currentColor" strokeWidth="1.7"/><path d="M3 11h18M12 7v13M8 7c0-3 4-3 4 0c0-3 4-3 4 0" stroke="currentColor" strokeWidth="1.7"/></svg> },
          { l: 'Discover', i: <svg width="22" height="22" viewBox="0 0 24 24"><circle cx="6" cy="6" r="2" fill="currentColor"/><circle cx="12" cy="6" r="2" fill="currentColor"/><circle cx="18" cy="6" r="2" fill="currentColor"/><circle cx="6" cy="12" r="2" fill="currentColor"/><circle cx="12" cy="12" r="2" fill="currentColor"/><circle cx="18" cy="12" r="2" fill="currentColor"/></svg> },
          { l: 'Me', i: <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="8" r="4" stroke="currentColor" strokeWidth="1.7"/><path d="M4 20c0-4 4-6 8-6s8 2 8 6" stroke="currentColor" strokeWidth="1.7"/></svg> },
        ].map((t, i) => (
          <div key={i} style={{
            display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4,
            color: t.a ? '#fff' : 'rgba(255,255,255,0.4)',
          }}>
            {t.i}
            <span style={{ fontSize: 10.5, fontWeight: 600 }}>{t.l}</span>
          </div>
        ))}
      </div>
    </div>
  );
}

function IconBtn({ children }) {
  return (
    <div style={{
      width: 36, height: 36, borderRadius: 12,
      background: 'rgba(255,255,255,0.06)', border: '1px solid rgba(255,255,255,0.08)',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
    }}>{children}</div>
  );
}

function ActionItem({ icon, label }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
      <div style={{
        width: 50, height: 50, borderRadius: '50%',
        background: 'linear-gradient(180deg, #A45EFF 0%, #8B3FFF 50%, #6A1ED9 100%)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        boxShadow: '0 8px 18px rgba(139,63,255,0.5), 0 1px 0 rgba(255,255,255,0.3) inset',
      }}>{icon}</div>
      <span style={{ fontSize: 12, color: '#fff', fontWeight: 600 }}>{label}</span>
    </div>
  );
}

function AccountCard({ label, amount, footer }) {
  return (
    <div style={{
      background: 'linear-gradient(180deg, rgba(255,255,255,0.05) 0%, rgba(255,255,255,0.02) 100%)',
      border: '1px solid rgba(255,255,255,0.08)',
      borderRadius: 16, padding: '12px 12px',
      minHeight: 124,
      display: 'flex', flexDirection: 'column', justifyContent: 'space-between',
    }}>
      <div>
        <div style={{ fontSize: 10.5, color: 'rgba(255,255,255,0.55)', fontWeight: 500, marginBottom: 4 }}>{label}</div>
        <div style={{ fontSize: 14, fontWeight: 800, color: '#fff', letterSpacing: '-0.02em', fontVariantNumeric: 'tabular-nums' }}>{amount}</div>
      </div>
      {footer}
    </div>
  );
}

// The new GXBuddy entry card — pulses, animated, irresistible
function BuddyCard({ onClick }) {
  return (
    <button onClick={onClick} style={{
      position: 'relative',
      padding: '12px 10px',
      borderRadius: 16,
      background: 'linear-gradient(180deg, rgba(139,63,255,0.28) 0%, rgba(255,61,126,0.18) 100%)',
      border: '1.5px solid rgba(216,180,254,0.55)',
      cursor: 'pointer', textAlign: 'left',
      minHeight: 124,
      display: 'flex', flexDirection: 'column', justifyContent: 'space-between',
      boxShadow: '0 10px 28px rgba(139,63,255,0.45), 0 0 0 1px rgba(255,255,255,0.06) inset',
      overflow: 'hidden', fontFamily: 'inherit',
      animation: 'buddy-glow 2.4s ease-in-out infinite',
    }}>
      {/* shine sweep */}
      <div style={{
        position: 'absolute', inset: 0, borderRadius: 16, pointerEvents: 'none',
        background: 'linear-gradient(110deg, transparent 30%, rgba(255,255,255,0.18) 50%, transparent 70%)',
        backgroundSize: '200% 100%',
        animation: 'shimmer 3.6s ease-in-out infinite',
      }}/>
      {/* tiny mascot */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', position: 'relative' }}>
        <MiniMascot/>
        <div style={{
          padding: '2px 6px', borderRadius: 99,
          background: 'rgba(34,199,150,0.22)', border: '1px solid rgba(34,199,150,0.5)',
          fontSize: 8.5, fontWeight: 800, color: '#5DE3B6', letterSpacing: '0.06em',
        }}>NEW</div>
      </div>
      <div style={{ position: 'relative' }}>
        <div style={{ fontSize: 10.5, color: 'rgba(255,255,255,0.65)', fontWeight: 500, marginBottom: 2 }}>GXBuddy</div>
        <div style={{ fontSize: 12, fontWeight: 800, color: '#fff', lineHeight: 1.2, marginBottom: 6 }}>
          Smart save buddy
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 4, fontSize: 10.5, color: '#FFE89A', fontWeight: 700 }}>
          <span>🔥 8d</span><span style={{ color: 'rgba(255,255,255,0.4)' }}>·</span><span>Tap →</span>
        </div>
      </div>
    </button>
  );
}

function MiniMascot() {
  return (
    <div style={{ width: 42, height: 42, position: 'relative', animation: 'mascot-float 3s ease-in-out infinite' }}>
      <window.Mascot state="calm" size={42}/>
    </div>
  );
}

function InsightChip({ color, label }) {
  return (
    <div style={{
      flex: 1, padding: '12px 14px', borderRadius: 14,
      background: `linear-gradient(180deg, ${color}1f, rgba(255,255,255,0.02))`,
      border: `1px solid ${color}44`,
      display: 'flex', alignItems: 'center', gap: 10,
    }}>
      <div style={{ width: 8, height: 8, borderRadius: '50%', background: color, boxShadow: `0 0 8px ${color}` }}/>
      <span style={{ fontSize: 12, color: '#fff', fontWeight: 600 }}>{label}</span>
    </div>
  );
}

Object.assign(window, { GXBankHome });
