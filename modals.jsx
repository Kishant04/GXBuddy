// GXBuddy — modals & overlays (refined)

const { GXButton, GXCard, COLORS } = window;

// ────────────────────────────────────────────────────────
// Modal shell
// ────────────────────────────────────────────────────────
function ModalShell({ open, onClose, children, accent, glowTop }) {
  return (
    <div style={{
      position: 'absolute', inset: 0, zIndex: 100,
      pointerEvents: open ? 'auto' : 'none',
    }}>
      <div onClick={onClose} style={{
        position: 'absolute', inset: 0,
        background: 'radial-gradient(circle at 50% 30%, rgba(20,5,55,0.55) 0%, rgba(2,0,10,0.85) 70%)',
        backdropFilter: 'blur(12px) saturate(140%)',
        WebkitBackdropFilter: 'blur(12px) saturate(140%)',
        opacity: open ? 1 : 0,
        transition: 'opacity .32s cubic-bezier(.2,.8,.2,1)',
      }}/>
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0,
        transform: open ? 'translateY(0)' : 'translateY(100%)',
        transition: 'transform .48s cubic-bezier(.16,.84,.32,1)',
      }}>
        <div style={{
          position: 'relative',
          background: `linear-gradient(180deg, #1F0A4D 0%, #0E0228 75%, #08001A 100%)`,
          borderRadius: '32px 32px 0 0',
          padding: '18px 20px 30px',
          border: `1px solid ${accent || 'rgba(255,255,255,0.08)'}`,
          borderBottom: 'none',
          boxShadow: '0 -30px 80px rgba(0,0,0,0.7), 0 -1px 0 rgba(255,255,255,0.06) inset',
          overflow: 'hidden',
        }}>
          {glowTop && (
            <div style={{
              position: 'absolute', top: -120, left: '50%', transform: 'translateX(-50%)',
              width: 320, height: 240, borderRadius: '50%',
              background: `radial-gradient(circle, ${glowTop}55 0%, transparent 70%)`,
              filter: 'blur(20px)', pointerEvents: 'none',
            }}/>
          )}
          <div style={{
            width: 40, height: 4, borderRadius: 99,
            background: 'rgba(255,255,255,0.18)', margin: '0 auto 16px',
            position: 'relative', zIndex: 1,
          }}/>
          <div style={{ position: 'relative', zIndex: 1 }}>{children}</div>
        </div>
      </div>
    </div>
  );
}

// ────────────────────────────────────────────────────────
// High-Risk — cinematic Pause-Before-You-Spend
// ────────────────────────────────────────────────────────
function HighRiskModal({ open, onClose, onCancel, onContinue, onRoundUp, amount = 100 }) {
  const [secs, setSecs] = React.useState(10);
  const [riskFill, setRiskFill] = React.useState(0);
  const [scoreNum, setScoreNum] = React.useState(0);

  React.useEffect(() => {
    if (!open) { setSecs(10); setRiskFill(0); setScoreNum(0); return; }
    // animate risk fill
    setTimeout(() => setRiskFill(82), 250);
    // count up score
    let s = 0;
    const scoreId = setInterval(() => {
      s += 4; if (s >= 82) { s = 82; clearInterval(scoreId); }
      setScoreNum(s);
    }, 22);
    // countdown
    const id = setInterval(() => setSecs(x => x > 0 ? x - 1 : 0), 1000);
    return () => { clearInterval(id); clearInterval(scoreId); };
  }, [open]);

  const ringPct = (secs / 10) * 100;
  const urgent = secs <= 3;

  return (
    <ModalShell open={open} onClose={onClose} accent="rgba(255,61,126,0.45)" glowTop={COLORS.pink}>
      <div style={{ textAlign: 'center', marginBottom: 16 }}>
        {/* countdown ring with pulse */}
        <div style={{
          position: 'relative', width: 108, height: 108, margin: '0 auto 14px',
          animation: urgent ? 'urgent-pulse .7s ease-in-out infinite' : 'gentle-pulse 2.4s ease-in-out infinite',
        }}>
          <div style={{
            position: 'absolute', inset: -8, borderRadius: '50%',
            background: `radial-gradient(circle, ${urgent ? COLORS.red : COLORS.pink}33 0%, transparent 70%)`,
            filter: 'blur(8px)',
          }}/>
          <svg viewBox="0 0 100 100" width="108" height="108" style={{ transform: 'rotate(-90deg)', position: 'relative' }}>
            <defs>
              <linearGradient id="ringGrad" x1="0" y1="0" x2="1" y2="1">
                <stop offset="0%" stopColor="#FFB347"/>
                <stop offset="50%" stopColor={COLORS.pink}/>
                <stop offset="100%" stopColor={COLORS.red}/>
              </linearGradient>
            </defs>
            <circle cx="50" cy="50" r="44" fill="none" stroke="rgba(255,255,255,0.06)" strokeWidth="5"/>
            <circle cx="50" cy="50" r="44" fill="none"
                    stroke="url(#ringGrad)" strokeWidth="5"
                    strokeLinecap="round"
                    strokeDasharray={`${ringPct * 2.764} 276.4`}
                    style={{ transition: 'stroke-dasharray 1s linear', filter: `drop-shadow(0 0 8px ${urgent ? COLORS.red : COLORS.pink})` }}/>
          </svg>
          <div style={{
            position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column',
            alignItems: 'center', justifyContent: 'center',
          }}>
            <div style={{ fontSize: 38, fontWeight: 800, color: '#fff', lineHeight: 1, fontVariantNumeric: 'tabular-nums', letterSpacing: '-0.04em' }}>{secs}</div>
            <div style={{ fontSize: 9, color: COLORS.textMute, letterSpacing: '0.16em', marginTop: 3, fontWeight: 700 }}>BREATHE</div>
          </div>
        </div>
        <div style={{ fontSize: 10.5, fontWeight: 800, color: '#FF7DA1', letterSpacing: '0.2em', textTransform: 'uppercase', marginBottom: 8 }}>· Pause Before You Spend ·</div>
        <div style={{ fontSize: 26, fontWeight: 800, color: '#fff', letterSpacing: '-0.035em', marginBottom: 6 }}>
          <span style={{ fontSize: 16, fontWeight: 600, color: COLORS.textSoft }}>RM</span>{amount.toFixed(2)}
          <span style={{ fontSize: 14, fontWeight: 500, color: COLORS.textSoft, marginLeft: 6 }}>· Shopee</span>
        </div>
        <div style={{ fontSize: 13, color: COLORS.textSoft, lineHeight: 1.5, padding: '0 14px' }}>
          This will push you <b style={{ color: '#FF8FB1' }}>past your weekly limit</b>. Take a beat — there's a smarter move below.
        </div>
      </div>

      {/* Risk meter */}
      <div style={{
        background: 'linear-gradient(180deg, rgba(255,61,126,0.12) 0%, rgba(255,61,126,0.04) 100%)',
        border: '1px solid rgba(255,61,126,0.28)',
        borderRadius: 16, padding: 14, marginBottom: 14,
      }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 7 }}>
            <div style={{
              width: 22, height: 22, borderRadius: 7,
              background: 'rgba(255,61,126,0.22)', border: '1px solid rgba(255,61,126,0.4)',
              display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 11,
            }}>⚠</div>
            <div style={{ fontSize: 12, color: COLORS.textSoft, fontWeight: 600 }}>Risk score</div>
          </div>
          <div style={{ fontSize: 22, fontWeight: 800, color: '#FF7DA1', fontVariantNumeric: 'tabular-nums', letterSpacing: '-0.025em' }}>
            {scoreNum}<span style={{ fontSize: 13, color: COLORS.textMute, fontWeight: 500 }}> / 100</span>
          </div>
        </div>
        <div style={{ height: 8, background: 'rgba(255,255,255,0.06)', borderRadius: 99, overflow: 'hidden', position: 'relative' }}>
          <div style={{
            width: `${riskFill}%`, height: '100%',
            background: `linear-gradient(90deg, #FBB347, ${COLORS.pink} 60%, ${COLORS.red})`,
            boxShadow: `0 0 14px ${COLORS.red}66`,
            transition: 'width 1.2s cubic-bezier(.2,.8,.2,1)',
            position: 'relative',
          }}>
            <div style={{
              position: 'absolute', right: 0, top: 0, bottom: 0, width: 3,
              background: '#fff', boxShadow: '0 0 8px rgba(255,255,255,0.8)',
            }}/>
          </div>
        </div>
        <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 5, fontSize: 9.5, color: COLORS.textMute, fontWeight: 600, letterSpacing: '0.06em' }}>
          <span>SAFE</span><span>WATCH</span><span>HIGH RISK</span>
        </div>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6, marginTop: 12 }}>
          {[
            { l: '🌙 Late-night purchase', c: COLORS.orange, d: 0 },
            { l: '📈 178% above weekly avg', c: COLORS.pink, d: 80 },
            { l: '📱 Phone bill due in 2d', c: '#60A5FA', d: 160 },
          ].map((t, i) => (
            <div key={i} style={{
              fontSize: 11, fontWeight: 600, padding: '5px 10px', borderRadius: 99,
              background: `${t.c}1c`, border: `1px solid ${t.c}55`, color: '#fff',
              animation: `chip-in .4s cubic-bezier(.2,.8,.2,1) ${t.d}ms backwards`,
            }}>{t.l}</div>
          ))}
        </div>
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
        <GXButton variant="success" full size="lg" onClick={onRoundUp}>
          <span style={{ fontSize: 17 }}>💎</span> Round Up RM2 to Emergency Instead
        </GXButton>
        <div style={{ display: 'flex', gap: 8 }}>
          <GXButton variant="ghost" full onClick={onContinue}>Continue Anyway</GXButton>
          <GXButton variant="pink" full onClick={onCancel}>Cancel — Smart move</GXButton>
        </div>
      </div>
    </ModalShell>
  );
}

// ────────────────────────────────────────────────────────
// Streak Shield Modal
// ────────────────────────────────────────────────────────
function StreakShieldModal({ open, onClose, onSend, onSoft, onIgnore }) {
  return (
    <ModalShell open={open} onClose={onClose} accent={`${COLORS.violet}88`} glowTop={COLORS.violet}>
      <div style={{ textAlign: 'center', marginBottom: 18 }}>
        <div style={{
          width: 84, height: 84, borderRadius: '50%', margin: '0 auto 14px',
          background: `linear-gradient(135deg, ${COLORS.violet}, ${COLORS.pink})`,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontSize: 42,
          boxShadow: `0 0 36px ${COLORS.violet}88, inset 0 1px 0 rgba(255,255,255,0.3)`,
          animation: 'gentle-pulse 1.6s ease-in-out infinite',
        }}>🛡️</div>
        <div style={{ fontSize: 10.5, fontWeight: 800, color: '#D6BFFF', letterSpacing: '0.18em', textTransform: 'uppercase', marginBottom: 6 }}>· Streak Shield Triggered ·</div>
        <div style={{ fontSize: 22, fontWeight: 800, color: '#fff', letterSpacing: '-0.03em', marginBottom: 8 }}>Kumar needs backup</div>
        <div style={{ fontSize: 13, color: COLORS.textSoft, lineHeight: 1.5, padding: '0 12px' }}>
          He's one purchase away from breaking the squad's 30-day streak. Rally for him?
        </div>
      </div>

      <div style={{
        background: 'rgba(255,255,255,0.04)',
        border: '1px solid rgba(255,255,255,0.08)',
        borderRadius: 14, padding: 12, marginBottom: 14,
        display: 'flex', alignItems: 'center', gap: 10,
      }}>
        <div style={{
          width: 38, height: 38, borderRadius: '50%',
          background: `linear-gradient(135deg, ${COLORS.pink}, ${COLORS.pinkDeep})`,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontSize: 14, fontWeight: 800, color: '#fff',
          boxShadow: `0 4px 12px ${COLORS.pink}55`,
        }}>K</div>
        <div style={{ flex: 1 }}>
          <div style={{ fontSize: 13.5, fontWeight: 700, color: '#fff' }}>Kumar · 51% to goal</div>
          <div style={{ fontSize: 11, color: COLORS.textSoft }}>🔥 5-day streak · attempting RM85 purchase</div>
        </div>
        <div style={{
          padding: '4px 9px', borderRadius: 99, fontSize: 10, fontWeight: 800,
          background: 'rgba(239,68,68,0.18)', color: '#FF9999',
          border: '1px solid rgba(239,68,68,0.4)', letterSpacing: '0.06em',
        }}>AT RISK</div>
      </div>

      <div style={{ fontSize: 10.5, color: COLORS.textMute, textAlign: 'center', marginBottom: 12, letterSpacing: '0.04em' }}>
        Privacy-safe — teammates never see balances, only %
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
        <GXButton variant="primary" full size="lg" onClick={onSend}>💪 Send "Hold Strong"</GXButton>
        <div style={{ display: 'flex', gap: 8 }}>
          <GXButton variant="soft" full onClick={onSoft}>Soft Block</GXButton>
          <GXButton variant="ghost" full onClick={onIgnore}>Ignore</GXButton>
        </div>
      </div>
    </ModalShell>
  );
}

// ────────────────────────────────────────────────────────
// Autopilot Configuration Modal
// ────────────────────────────────────────────────────────
function AutopilotConfig({ open, onClose, autopilot, setAutopilot }) {
  return (
    <ModalShell open={open} onClose={onClose} accent={`${COLORS.violet}66`} glowTop={COLORS.violet}>
      <div style={{ textAlign: 'center', marginBottom: 18 }}>
        <div style={{ fontSize: 10.5, fontWeight: 800, color: '#D6BFFF', letterSpacing: '0.18em', textTransform: 'uppercase', marginBottom: 6 }}>· Salary Autopilot ·</div>
        <div style={{ fontSize: 24, fontWeight: 800, color: '#fff', letterSpacing: '-0.03em', marginBottom: 6 }}>Set it once. Save forever.</div>
        <div style={{ fontSize: 12.5, color: COLORS.textSoft, padding: '0 16px', lineHeight: 1.5 }}>
          GXBuddy splits your salary into pockets the moment it lands.
        </div>
      </div>

      <ConfigBlock label="Salary detection threshold" hint={`Trigger autopilot for credits above RM${autopilot.threshold}`}>
        <div style={{ display: 'flex', alignItems: 'baseline', gap: 4, marginBottom: 10 }}>
          <span style={{ fontSize: 13, color: COLORS.textSoft }}>RM</span>
          <span style={{ fontSize: 30, fontWeight: 800, color: '#fff', fontVariantNumeric: 'tabular-nums', letterSpacing: '-0.025em' }}>{autopilot.threshold}</span>
        </div>
        <input type="range" min="200" max="3000" step="100" value={autopilot.threshold}
               onChange={(e) => setAutopilot({ ...autopilot, threshold: +e.target.value })}
               style={{ width: '100%', accentColor: COLORS.violet }}/>
        <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 10.5, color: COLORS.textMute, marginTop: 2 }}>
          <span>RM200</span><span>RM3,000</span>
        </div>
      </ConfigBlock>

      <ConfigBlock label="Income type">
        <SegmentControl
          options={[
            { v: 'monthly', l: 'Monthly salary', icon: '💼' },
            { v: 'gig', l: 'Gig income', icon: '🛵' },
          ]}
          value={autopilot.income} onChange={(v) => setAutopilot({ ...autopilot, income: v })}
        />
      </ConfigBlock>

      <ConfigBlock label="Split rule">
        <SegmentControl
          options={[
            { v: 'fixed', l: 'Fixed RM', icon: '💵' },
            { v: 'percent', l: 'Percentage', icon: '%' },
          ]}
          value={autopilot.split} onChange={(v) => setAutopilot({ ...autopilot, split: v })}
        />
      </ConfigBlock>

      <ConfigBlock label="Pocket allocation">
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          <AllocRow icon="🛟" name="Emergency Fund" v={20} c="#22C796" suffix="%"/>
          <AllocRow icon="📚" name="PTPTN" v={10} c="#60A5FA" suffix="%"/>
          <AllocRow icon="✈️" name="Travel" v={5} c={COLORS.pink} suffix="%"/>
        </div>
      </ConfigBlock>

      <GXButton variant="primary" full size="lg" onClick={onClose} style={{ marginTop: 4 }}>Save rule</GXButton>
    </ModalShell>
  );
}

function ConfigBlock({ label, hint, children }) {
  return (
    <div style={{ marginBottom: 14 }}>
      <div style={{ fontSize: 10.5, fontWeight: 800, color: COLORS.textSoft, letterSpacing: '0.14em', textTransform: 'uppercase', marginBottom: 8 }}>{label}</div>
      <div style={{
        background: 'rgba(255,255,255,0.035)',
        border: `1px solid ${COLORS.border}`,
        borderRadius: 14, padding: 14,
      }}>
        {children}
        {hint && <div style={{ fontSize: 11, color: COLORS.textMute, marginTop: 8 }}>{hint}</div>}
      </div>
    </div>
  );
}

function SegmentControl({ options, value, onChange }) {
  return (
    <div style={{ display: 'grid', gridTemplateColumns: `repeat(${options.length}, 1fr)`, gap: 6, padding: 4, background: 'rgba(0,0,0,0.35)', borderRadius: 12 }}>
      {options.map(o => (
        <button key={o.v} onClick={() => onChange(o.v)} style={{
          padding: '10px 8px', borderRadius: 9,
          background: value === o.v ? `linear-gradient(180deg, #A45EFF, ${COLORS.violetDeep})` : 'transparent',
          border: 'none', cursor: 'pointer',
          color: value === o.v ? '#fff' : COLORS.textSoft,
          fontSize: 12.5, fontWeight: 600, fontFamily: 'inherit',
          boxShadow: value === o.v ? `0 4px 14px ${COLORS.violet}66, 0 1px 0 rgba(255,255,255,0.25) inset` : 'none',
          transition: 'all .2s',
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
        }}><span>{o.icon}</span>{o.l}</button>
      ))}
    </div>
  );
}

function AllocRow({ icon, name, v, c, suffix }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
      <div style={{
        width: 30, height: 30, borderRadius: 9,
        background: `${c}1f`, border: `1px solid ${c}55`,
        display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 14,
      }}>{icon}</div>
      <div style={{ flex: 1, fontSize: 13, fontWeight: 600, color: '#fff' }}>{name}</div>
      <div style={{
        padding: '5px 11px', borderRadius: 8,
        background: `${c}22`, color: c, border: `1px solid ${c}55`,
        fontSize: 13.5, fontWeight: 800, fontVariantNumeric: 'tabular-nums',
      }}>{v}{suffix}</div>
    </div>
  );
}

// ────────────────────────────────────────────────────────
// CINEMATIC Salary Autopilot moment
// 4-stage choreography: detect → split → fly → settle
// ────────────────────────────────────────────────────────
function SalarySplash({ open, onComplete }) {
  const [stage, setStage] = React.useState(0);
  // 0: hidden  1: detect ping  2: amount reveal  3: splitting  4: settled
  React.useEffect(() => {
    if (!open) { setStage(0); return; }
    const t1 = setTimeout(() => setStage(1), 60);     // SMS ping
    const t2 = setTimeout(() => setStage(2), 700);    // big number
    const t3 = setTimeout(() => setStage(3), 1700);   // splitting
    const t4 = setTimeout(() => setStage(4), 4200);   // settled
    const t5 = setTimeout(() => onComplete && onComplete(), 5200);
    return () => [t1,t2,t3,t4,t5].forEach(clearTimeout);
  }, [open]);
  if (!open) return null;

  const pockets = [
    { name: 'Emergency', amt: 240, color: '#22C796', icon: '🛟', x: -88 },
    { name: 'PTPTN',     amt: 120, color: '#60A5FA', icon: '📚', x:   0 },
    { name: 'Travel',    amt:  60, color: COLORS.pink, icon: '✈️', x:  88 },
  ];

  return (
    <div style={{
      position: 'absolute', inset: 0, zIndex: 95, overflow: 'hidden',
      background: 'rgba(2,0,10,0.92)',
      backdropFilter: 'blur(14px) saturate(160%)',
      WebkitBackdropFilter: 'blur(14px) saturate(160%)',
      animation: 'salary-fade-in .35s ease-out',
    }}>
      {/* Radial bloom */}
      <div style={{
        position: 'absolute', top: '32%', left: '50%', transform: 'translate(-50%, -50%)',
        width: 480, height: 480, borderRadius: '50%',
        background: `radial-gradient(circle, ${COLORS.violet}55 0%, ${COLORS.pink}22 35%, transparent 70%)`,
        filter: 'blur(24px)',
        animation: 'salary-bloom 4s ease-out',
      }}/>
      {/* Confetti rays */}
      {stage >= 2 && Array.from({ length: 14 }).map((_, i) => (
        <div key={i} style={{
          position: 'absolute',
          top: '32%', left: '50%',
          width: 2, height: 60,
          background: `linear-gradient(180deg, ${[COLORS.violet, COLORS.pink, COLORS.gold, COLORS.greenLight][i%4]}, transparent)`,
          transformOrigin: '50% 0%',
          transform: `translate(-50%, 0) rotate(${i * (360/14)}deg)`,
          animation: `ray-burst 1s cubic-bezier(.2,.8,.2,1) ${i * 30}ms forwards`,
          opacity: 0,
        }}/>
      ))}

      {/* Stage label */}
      <div style={{
        position: 'absolute', top: '14%', left: 0, right: 0, textAlign: 'center',
        color: '#D6BFFF', fontSize: 11, fontWeight: 800, letterSpacing: '0.22em',
      }}>
        {stage <= 1 && '· DETECTING SALARY ·'}
        {stage === 2 && '· INCOMING ·'}
        {stage === 3 && '· AUTOPILOT ENGAGED ·'}
        {stage >= 4 && '· DONE ·'}
      </div>

      {/* SMS-style detection ping */}
      {stage <= 1 && (
        <div style={{
          position: 'absolute', top: '24%', left: '50%', transform: 'translateX(-50%)',
          padding: '10px 16px', borderRadius: 16,
          background: 'rgba(255,255,255,0.07)', border: '1px solid rgba(255,255,255,0.1)',
          backdropFilter: 'blur(10px)',
          color: '#fff', fontSize: 12.5, display: 'flex', alignItems: 'center', gap: 10,
          animation: 'sms-pop .5s cubic-bezier(.2,.8,.2,1)',
        }}>
          <div style={{
            width: 8, height: 8, borderRadius: '50%', background: COLORS.greenLight,
            boxShadow: `0 0 12px ${COLORS.greenLight}`, animation: 'gentle-pulse 1s ease-in-out infinite',
          }}/>
          <span style={{ color: COLORS.textSoft }}>Maybank · Credit Alert</span>
          <span style={{ color: '#fff', fontWeight: 700 }}>RM1,200.00</span>
        </div>
      )}

      {/* Big amount reveal */}
      {stage >= 2 && (
        <div style={{
          position: 'absolute', top: stage === 2 ? '28%' : '24%', left: 0, right: 0,
          textAlign: 'center', transition: 'top .9s cubic-bezier(.2,.8,.2,1)',
        }}>
          <div style={{
            fontSize: stage === 2 ? 56 : 38, fontWeight: 800,
            background: `linear-gradient(180deg, #fff 0%, ${COLORS.gold} 100%)`,
            WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent',
            letterSpacing: '-0.04em', lineHeight: 1,
            textShadow: stage === 2 ? `0 0 40px ${COLORS.gold}66` : 'none',
            transition: 'font-size .9s cubic-bezier(.2,.8,.2,1)',
            animation: 'amount-pop .6s cubic-bezier(.2,.8,.2,1)',
          }}>
            +RM1,200<span style={{ fontSize: '0.55em', opacity: 0.7 }}>.00</span>
          </div>
          <div style={{ fontSize: 12, color: COLORS.textSoft, marginTop: 6, letterSpacing: '0.08em' }}>
            {stage === 2 ? 'Salary received from Maybank' : 'Salary · 8 May 2026'}
          </div>
        </div>
      )}

      {/* Flying coins from center to pockets */}
      {stage >= 3 && Array.from({ length: 18 }).map((_, i) => {
        const target = pockets[i % 3];
        const startX = (Math.random() - 0.5) * 40;
        return (
          <div key={i} style={{
            position: 'absolute', top: '32%', left: '50%',
            transform: `translate(calc(-50% + ${startX}px), 0)`,
            animation: `coin-fly 1.4s cubic-bezier(.5,0,.6,1) ${i * 50}ms forwards`,
            ['--tx']: `${target.x}px`,
            ['--ty']: '230px',
          }}>
            <div style={{
              width: 22, height: 22, borderRadius: '50%',
              background: `radial-gradient(circle at 35% 30%, #FFE89A 0%, ${COLORS.gold} 60%, #C9952A 100%)`,
              border: `1.5px solid #FFE89A`,
              boxShadow: `0 0 14px ${COLORS.gold}88`,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontSize: 10, fontWeight: 800, color: '#7A4A00',
            }}>$</div>
          </div>
        );
      })}

      {/* Three pocket targets */}
      <div style={{
        position: 'absolute', top: '60%', left: 0, right: 0,
        display: 'flex', justifyContent: 'center', gap: 12, padding: '0 24px',
      }}>
        {pockets.map((p, i) => (
          <div key={p.name} style={{
            flex: 1, maxWidth: 110,
            background: stage >= 3 ? `linear-gradient(180deg, ${p.color}1f, ${p.color}08)` : 'rgba(255,255,255,0.03)',
            border: `1px solid ${stage >= 3 ? p.color + '55' : 'rgba(255,255,255,0.08)'}`,
            borderRadius: 18, padding: '14px 10px 12px', textAlign: 'center',
            transition: 'all .5s',
            transform: stage >= 4 ? 'scale(1)' : stage >= 3 ? `scale(${1 + 0.04 * Math.sin(Date.now()/500 + i)})` : 'scale(0.98)',
            boxShadow: stage >= 4 ? `0 8px 24px ${p.color}55, 0 0 0 1px ${p.color}66` : 'none',
            animation: stage >= 3 ? `pocket-receive 1.6s cubic-bezier(.2,.8,.2,1) ${i*120 + 800}ms` : 'none',
          }}>
            <div style={{
              width: 36, height: 36, margin: '0 auto 6px', borderRadius: 11,
              background: `linear-gradient(135deg, ${p.color}, ${p.color}cc)`,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontSize: 18,
              boxShadow: `0 6px 16px ${p.color}66`,
            }}>{p.icon}</div>
            <div style={{ fontSize: 10.5, color: COLORS.textSoft, fontWeight: 600 }}>{p.name}</div>
            <div style={{
              fontSize: 16, fontWeight: 800, color: '#fff', marginTop: 2,
              fontVariantNumeric: 'tabular-nums', letterSpacing: '-0.02em',
            }}>+RM{p.amt}</div>
            <div style={{ fontSize: 9, color: p.color, fontWeight: 700, marginTop: 1 }}>
              {[20,10,5][i]}%
            </div>
          </div>
        ))}
      </div>

      {/* Bottom status */}
      <div style={{
        position: 'absolute', bottom: '14%', left: 0, right: 0, textAlign: 'center',
      }}>
        <div style={{
          display: 'inline-flex', alignItems: 'center', gap: 8,
          padding: '8px 14px', borderRadius: 99,
          background: stage >= 4 ? `${COLORS.greenLight}1f` : 'rgba(255,255,255,0.05)',
          border: `1px solid ${stage >= 4 ? COLORS.greenLight + '55' : 'rgba(255,255,255,0.1)'}`,
          fontSize: 12, fontWeight: 700, color: stage >= 4 ? '#5DE3B6' : '#fff',
          transition: 'all .4s',
        }}>
          {stage >= 4 ? (
            <><span>✓</span> RM420 saved before you could spend it</>
          ) : stage >= 3 ? (
            <><span style={{
              width: 10, height: 10, borderRadius: '50%', background: COLORS.violet,
              animation: 'gentle-pulse .8s ease-in-out infinite',
            }}/> Splitting into 3 pockets…</>
          ) : (
            <>· GXBuddy is on it ·</>
          )}
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { HighRiskModal, StreakShieldModal, AutopilotConfig, SalarySplash, ModalShell });
