// GXBuddy — main app

const { useState, useEffect, useRef } = React;
const {
  COLORS, GXCard, GXButton, Mascot, BottomNav, Toast,
  HomeScreen, SpendScreen, PocketsScreen, SquadScreen, ProfileScreen,
  HighRiskModal, StreakShieldModal, AutopilotConfig, SalarySplash,
  IOSDevice,
} = window;

// ────────────────────────────────────────────────────────
// Initial state / mock data
// ────────────────────────────────────────────────────────
const INITIAL = {
  mascotState: 'alert',
  streak: 8,
  alertsDismissed: false,
  budget: {
    food: { spent: 148, cap: 150 },
    transport: { spent: 45, cap: 100 },
    shopping: { spent: 90, cap: 120 },
  },
  weeklyTotal: 312.50,
  pockets: [
    { name: 'Emergency Fund', value: 240, goal: 580, color: '#1FB287', icon: '🛟', note: 'Auto · 20% of salary', eta: 'Goal in 4 mo' },
    { name: 'PTPTN', value: 120, goal: 500, color: '#3B82F6', icon: '📚', note: 'Auto · 10% of salary', eta: 'Goal in 7 mo' },
    { name: 'Travel', value: 90, goal: 300, color: '#F8326D', icon: '✈️', note: 'Auto · 5% of salary', eta: 'Bali · Dec' },
  ],
  autopilot: { threshold: 800, income: 'monthly', split: 'percent', lastSplit: 0 },
  squad: {
    name: 'Broke No More Squad',
    progress: 64,
    members: [
      { name: 'Aiman', initials: 'A', progress: 72, streak: 8, color: '#A855F7', status: 'On track', you: true },
      { name: 'Mei',   initials: 'M', progress: 65, streak: 6, color: '#1FB287', status: 'On track' },
      { name: 'Kumar', initials: 'K', progress: 51, streak: 5, color: '#F8326D', status: 'Needs nudge' },
      { name: 'Sarah', initials: 'S', progress: 68, streak: 7, color: '#3B82F6', status: 'On track' },
    ],
  },
  toggles: { push: true, whatsapp: true, telegram: false, anon: false, hideBalance: true },
  transactions: [
    { name: 'GrabFood', amount: 32.00, time: 'Today · 8:42pm', category: 'Food', risk: 'Risky', glyph: '🍔', color: '#10B981' },
    { name: 'Touch \'n Go', amount: 15.00, time: 'Today · 7:30am', category: 'Transport', risk: 'Essential', glyph: 'T', color: '#3B82F6' },
    { name: 'Shopee', amount: 89.00, time: 'Yesterday · 11:18pm', category: 'Shopping', risk: 'Unusual', glyph: 'S', color: '#F8326D' },
    { name: 'Spotify', amount: 14.90, time: 'Mon · 9:00am', category: 'Lifestyle', risk: 'Lifestyle', glyph: '♫', color: '#1DB954' },
    { name: 'Salary Credit', amount: 1200.00, time: 'Last week', category: 'Income', risk: 'Income', glyph: '$', color: '#7C3AED', income: true },
    { name: 'GrabFood', amount: 28.50, time: 'Mon · 1:15pm', category: 'Food', risk: 'Risky', glyph: '🍔', color: '#10B981' },
  ],
};

function App() {
  const [view, setView] = useState('bank'); // 'bank' | 'buddy'
  const [tab, setTab] = useState('home');
  const [state, setState] = useState(INITIAL);
  const [highRisk, setHighRisk] = useState(false);
  const [shield, setShield] = useState(false);
  const [config, setConfig] = useState(false);
  const [salary, setSalary] = useState(false);
  const [toast, setToast] = useState(null);
  const undoTimeoutRef = useRef();

  const showToast = (msg, opts = {}) => {
    setToast({ msg, ...opts });
    clearTimeout(undoTimeoutRef.current);
    undoTimeoutRef.current = setTimeout(() => setToast(null), opts.duration || 3500);
  };

  const triggerMascot = (s, ms = 2400) => {
    setState(p => ({ ...p, mascotState: s }));
    setTimeout(() => {
      setState(p => {
        // re-evaluate based on budget after timeout
        const total = p.budget.food.spent + p.budget.transport.spent + p.budget.shopping.spent;
        const cap = p.budget.food.cap + p.budget.transport.cap + p.budget.shopping.cap;
        const pct = total / cap;
        const newState = pct >= 1 ? 'panicked' : pct >= 0.6 ? 'alert' : 'calm';
        return { ...p, mascotState: newState };
      });
    }, ms);
  };

  const actions = {
    spendFood(amt) {
      setState(p => {
        const next = { ...p,
          budget: { ...p.budget, food: { ...p.budget.food, spent: p.budget.food.spent + amt } },
          weeklyTotal: p.weeklyTotal + amt,
          transactions: [
            { name: 'GrabFood', amount: amt, time: 'Just now', category: 'Food', risk: 'Risky', glyph: '🍔', color: '#10B981' },
            ...p.transactions,
          ],
        };
        const tot = next.budget.food.spent + next.budget.transport.spent + next.budget.shopping.spent;
        const cap = next.budget.food.cap + next.budget.transport.cap + next.budget.shopping.cap;
        next.mascotState = (tot/cap) >= 1 ? 'panicked' : (tot/cap) >= 0.6 ? 'alert' : 'calm';
        return next;
      });
      showToast(`RM${amt} spent on Food. GXBuddy is ${state.mascotState === 'panicked' ? 'panicked' : 'alert'} 👀`, { accent: COLORS.pink });
    },
    attemptShopping(amt) {
      setHighRisk(true);
    },
    receiveSalary() {
      setSalary(true);
      // big cinematic moment runs ~5s
      setState(p => ({
        ...p,
        pockets: p.pockets.map((pk, i) => ({
          ...pk,
          value: pk.value + [240, 120, 60][i],
        })),
        autopilot: { ...p.autopilot, lastSplit: 420 },
        transactions: [
          { name: 'Salary Credit', amount: 1200, time: 'Just now', category: 'Income', risk: 'Income', glyph: '$', color: '#7C3AED', income: true },
          ...p.transactions,
        ],
      }));
      triggerMascot('celebrating', 4000);
      setTimeout(() => {
        showToast(`RM420 saved into your GX Pockets.`, {
          accent: COLORS.violet, duration: 7000,
          action: 'Undo',
          onAction: () => {
            setState(p => ({
              ...p,
              pockets: p.pockets.map((pk, i) => ({
                ...pk, value: pk.value - [240, 120, 60][i],
              })),
            }));
            showToast('Salary split undone.', { accent: COLORS.orange });
          },
        });
      }, 5400);
    },
    save(amt) {
      setState(p => ({
        ...p,
        pockets: p.pockets.map((pk, i) => i === 0 ? { ...pk, value: pk.value + amt } : pk),
      }));
      triggerMascot('celebrating', 2400);
      showToast(`RM${amt} saved into Emergency Fund 🎉`, { accent: COLORS.greenLight });
    },
    roundUp(amt) {
      setState(p => ({
        ...p,
        pockets: p.pockets.map((pk, i) => i === 0 ? { ...pk, value: pk.value + amt } : pk),
        alertsDismissed: true,
      }));
      triggerMascot('celebrating', 2400);
      showToast(`RM${amt} rounded up into Emergency Fund 💎`, { accent: COLORS.greenLight });
    },
    dismissAlert() {
      setState(p => ({ ...p, alertsDismissed: true }));
    },
    toggle(key) {
      setState(p => ({ ...p, toggles: { ...p.toggles, [key]: !p.toggles[key] } }));
    },
  };

  // High-risk modal handlers
  const closeHighRisk = () => setHighRisk(false);
  const onHighRiskCancel = () => {
    setHighRisk(false);
    triggerMascot('calm', 2200);
    showToast('Smart move — transaction cancelled.', { accent: COLORS.greenLight });
  };
  const onHighRiskContinue = () => {
    setHighRisk(false);
    setState(p => {
      const next = { ...p,
        budget: { ...p.budget, shopping: { ...p.budget.shopping, spent: p.budget.shopping.spent + 100 } },
        weeklyTotal: p.weeklyTotal + 100,
        transactions: [
          { name: 'Shopee', amount: 100, time: 'Just now', category: 'Shopping', risk: 'Risky', glyph: 'S', color: '#F8326D' },
          ...p.transactions,
        ],
        mascotState: 'panicked',
      };
      return next;
    });
    showToast('Pushed past your weekly limit. GXBuddy is panicking 😬', { accent: COLORS.red });
  };
  const onHighRiskRoundUp = () => {
    setHighRisk(false);
    actions.roundUp(2);
  };

  // Streak shield
  const onShieldSend = () => { setShield(false); showToast('Hold Strong sent to Kumar 💪', { accent: COLORS.violet }); };
  const onShieldSoft  = () => { setShield(false); showToast('Soft block requested. Kumar will be asked to confirm.', { accent: COLORS.orange }); };
  const onShieldIgnore = () => setShield(false);

  const screens = {
    home: <HomeScreen state={state} actions={actions}/>,
    spend: <SpendScreen state={state}/>,
    pockets: <PocketsScreen state={state} actions={actions} openConfig={() => setConfig(true)}/>,
    squad: <SquadScreen state={state} actions={actions} openShield={() => setShield(true)}/>,
    profile: <ProfileScreen state={state} actions={actions}/>,
  };

  const titles = { home: 'GXBuddy', spend: 'Spend', pockets: 'Pockets', squad: 'Squad', profile: 'Profile' };

  return (
    <div style={{
      minHeight: '100vh', width: '100%',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      background: `radial-gradient(circle at 30% 10%, #2a0a5a 0%, #0C0121 50%, #050010 100%)`,
      padding: '20px 12px',
      position: 'relative',
    }}>
      <BackgroundDecor/>
      <PhoneShell view={view} setView={setView} tab={tab} setTab={setTab} title={titles[tab]}>
        {view === 'bank' ? (
          <window.GXBankHome onOpenBuddy={() => setView('buddy')}/>
        ) : (
          <>
            {screens[tab]}
            <SalarySplash open={salary} onComplete={() => setSalary(false)}/>
            <HighRiskModal open={highRisk} onClose={closeHighRisk}
                           onCancel={onHighRiskCancel}
                           onContinue={onHighRiskContinue}
                           onRoundUp={onHighRiskRoundUp}
                           amount={100}/>
            <StreakShieldModal open={shield} onClose={() => setShield(false)}
                               onSend={onShieldSend} onSoft={onShieldSoft} onIgnore={onShieldIgnore}/>
            <AutopilotConfig open={config} onClose={() => setConfig(false)}
                             autopilot={state.autopilot}
                             setAutopilot={(a) => setState(p => ({ ...p, autopilot: a }))}/>
            <Toast visible={!!toast} accent={toast?.accent} action={toast?.action} onAction={toast?.onAction}>
              {toast?.msg}
            </Toast>
            <BottomNav tab={tab} setTab={setTab}/>
          </>
        )}
      </PhoneShell>
      <DemoStoryGuide/>
    </div>
  );
}

// ────────────────────────────────────────────────────────
// Phone shell — original branded chrome (no copyrighted UI)
// ────────────────────────────────────────────────────────
function PhoneShell({ children, view, setView, tab, title }) {
  return (
    <IOSDevice dark width={392} height={812}>
      <div style={{
        height: '100%', width: '100%',
        background: `radial-gradient(circle at 80% 0%, #1F0A4A 0%, #0C0121 60%)`,
        position: 'relative', overflow: 'hidden',
      }}>
        {view === 'buddy' && (
          <>
            <div style={{ paddingTop: 56, paddingBottom: 4, paddingLeft: 18, paddingRight: 18,
                           display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                <button onClick={() => setView('bank')} style={{
                  width: 32, height: 32, borderRadius: 10,
                  background: 'rgba(255,255,255,0.06)', border: '1px solid rgba(255,255,255,0.1)',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  cursor: 'pointer', padding: 0,
                }}>
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M15 6l-6 6 6 6" stroke="#fff" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>
                </button>
                <BrandMark/>
                <span style={{ fontSize: 16, fontWeight: 800, color: '#fff', letterSpacing: '-0.02em' }}>GXBuddy</span>
              </div>
              <div style={{ fontSize: 11, fontWeight: 600,
                            padding: '4px 9px', borderRadius: 99,
                            background: 'rgba(31,178,135,0.12)',
                            border: '1px solid rgba(31,178,135,0.3)',
                            color: '#5DE3B6' }}>● Live</div>
            </div>
            <div style={{ position: 'absolute', top: 56, left: 0, right: 0, bottom: 0, overflowY: 'auto' }}>
              <div style={{ paddingTop: 28 }}/>
              {children}
            </div>
          </>
        )}
        {view === 'bank' && children}
      </div>
    </IOSDevice>
  );
}

function BrandMark() {
  return (
    <div style={{
      width: 28, height: 28, borderRadius: 9,
      background: `linear-gradient(135deg, ${COLORS.violet} 0%, ${COLORS.pink} 100%)`,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      boxShadow: `0 4px 12px ${COLORS.violet}66, inset 0 1px 0 rgba(255,255,255,0.3)`,
      position: 'relative',
    }}>
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
        <path d="M12 2C7 2 4 5.5 4 10c0 5 4 8 8 12 4-4 8-7 8-12 0-4.5-3-8-8-8z"
              fill="#fff" fillOpacity="0.95"/>
        <circle cx="9.5" cy="9.5" r="1.4" fill="#0C0121"/>
        <circle cx="14.5" cy="9.5" r="1.4" fill="#0C0121"/>
        <path d="M9 13c1 1.5 5 1.5 6 0" stroke="#0C0121" strokeWidth="1.4" strokeLinecap="round"/>
      </svg>
    </div>
  );
}

function BackgroundDecor() {
  return (
    <>
      <div style={{
        position: 'fixed', top: '15%', left: '8%', width: 200, height: 200,
        borderRadius: '50%', filter: 'blur(80px)',
        background: 'rgba(119,31,255,0.4)', pointerEvents: 'none',
      }}/>
      <div style={{
        position: 'fixed', bottom: '10%', right: '5%', width: 240, height: 240,
        borderRadius: '50%', filter: 'blur(100px)',
        background: 'rgba(248,50,109,0.25)', pointerEvents: 'none',
      }}/>
    </>
  );
}

// Demo story guide on the right (desktop)
function DemoStoryGuide() {
  const [open, setOpen] = useState(true);
  return (
    <div style={{
      position: 'fixed', right: 24, top: '50%', transform: 'translateY(-50%)',
      maxWidth: 280, zIndex: 5,
    }} className="story-guide">
      <button onClick={() => setOpen(!open)} style={{
        background: 'rgba(255,255,255,0.06)', border: '1px solid rgba(255,255,255,0.1)',
        color: '#fff', padding: '8px 12px', borderRadius: 10, fontSize: 12, fontWeight: 600,
        cursor: 'pointer', marginBottom: 10, fontFamily: 'inherit',
        display: 'flex', alignItems: 'center', gap: 6,
      }}>{open ? '✕ Hide' : '? Demo flow'}</button>
      {open && (
        <div style={{
          background: 'rgba(20,5,55,0.85)', backdropFilter: 'blur(20px)',
          border: '1px solid rgba(255,255,255,0.08)', borderRadius: 16, padding: 16,
          color: '#fff', fontSize: 12.5, lineHeight: 1.55,
        }}>
          <div style={{ fontSize: 11, fontWeight: 700, color: '#C9A8FF', letterSpacing: '0.12em', textTransform: 'uppercase', marginBottom: 8 }}>Demo flow</div>
          <ol style={{ margin: 0, paddingLeft: 18, color: 'rgba(255,255,255,0.85)' }}>
            <li>Mascot is alert · food budget is hot</li>
            <li>Tap <b>Spend RM100 Shopping</b> → Pause modal</li>
            <li>Choose <b>Round Up & Save</b> or Cancel</li>
            <li>Tap <b>Receive Salary</b> → autopilot splits</li>
            <li>Open <b>Squad</b> → send Hold Strong</li>
          </ol>
        </div>
      )}
      <style>{`@media (max-width: 920px) { .story-guide { display: none; } }`}</style>
    </div>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App/>);
