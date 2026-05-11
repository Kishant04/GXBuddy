// GXBuddy — screens

const { GXCard, GXButton, Mascot, ProgressBar, SectionHeader, MerchantIcon, COLORS } = window;

// ────────────────────────────────────────────────────────
// Home
// ────────────────────────────────────────────────────────
function HomeScreen({ state, actions }) {
  const { mascotState, budget, streak, alertsDismissed } = state;
  const moodLines = {
    calm: "Looking good 💚 You're on track this week.",
    alert: "You've used 78% of your food budget and it's only Wednesday 👀",
    panicked: "Whoa — that pushed you past your weekly limit 😬",
    celebrating: "Proud of you! Another deposit into your future 🎉",
  };
  const totalSpend = budget.food.spent + budget.transport.spent + budget.shopping.spent;
  const totalBudget = budget.food.cap + budget.transport.cap + budget.shopping.cap;

  return (
    <div style={{ padding: '8px 18px 130px' }}>
      {/* Greeting */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 18 }}>
        <div>
          <div style={{ fontSize: 13, color: COLORS.textSoft, marginBottom: 2 }}>Wed, 8 May</div>
          <div style={{ fontSize: 24, fontWeight: 700, color: '#fff', letterSpacing: '-0.02em' }}>Hi Aiman 👋</div>
        </div>
        <div style={{ display: 'flex', gap: 8 }}>
          <div style={{
            width: 40, height: 40, borderRadius: 12, background: 'rgba(255,255,255,0.06)',
            border: '1px solid rgba(255,255,255,0.08)',
            display: 'flex', alignItems: 'center', justifyContent: 'center', position: 'relative',
          }}>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M6 8a6 6 0 1112 0v5l1.5 3h-15L6 13V8z" stroke="#fff" strokeWidth="1.7"/><path d="M10 19a2 2 0 004 0" stroke="#fff" strokeWidth="1.7"/></svg>
            <div style={{ position: 'absolute', top: 8, right: 9, width: 8, height: 8, borderRadius: '50%', background: COLORS.pink, boxShadow: `0 0 8px ${COLORS.pink}` }}/>
          </div>
        </div>
      </div>

      {/* Mascot card */}
      <GXCard glow={
        mascotState === 'calm' ? COLORS.greenLight :
        mascotState === 'alert' ? COLORS.orange :
        mascotState === 'panicked' ? COLORS.red : '#A855F7'
      } padding={20} style={{ marginBottom: 16, overflow: 'hidden' }}>
        <div style={{ display: 'flex', gap: 14, alignItems: 'center' }}>
          <Mascot state={mascotState} size={96} />
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: '0.12em', color: COLORS.textSoft, textTransform: 'uppercase', marginBottom: 4 }}>
              GXBuddy · {mascotState}
            </div>
            <div style={{ fontSize: 14.5, lineHeight: 1.4, color: '#fff', fontWeight: 500 }}>
              {moodLines[mascotState]}
            </div>
            <div style={{ display: 'flex', gap: 6, marginTop: 10 }}>
              <Pill icon="🔥" label={`${streak}d streak`} />
              <Pill icon="🛡️" label="Shield on" />
            </div>
          </div>
        </div>
      </GXCard>

      {/* Budget card */}
      <GXCard padding={18} style={{ marginBottom: 14 }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 14 }}>
          <div>
            <div style={{ fontSize: 12, color: COLORS.textSoft, marginBottom: 4 }}>Weekly spend</div>
            <div style={{ fontSize: 26, fontWeight: 800, color: '#fff', letterSpacing: '-0.03em', fontVariantNumeric: 'tabular-nums' }}>
              RM{totalSpend.toFixed(2)} <span style={{ fontSize: 14, fontWeight: 500, color: COLORS.textSoft }}>/ RM{totalBudget}</span>
            </div>
          </div>
          <div style={{
            padding: '5px 10px', borderRadius: 999,
            background: 'rgba(217,119,6,0.18)', color: '#FFB95C',
            fontSize: 12, fontWeight: 700, border: '1px solid rgba(217,119,6,0.35)',
          }}>{Math.round((totalSpend/totalBudget)*100)}% used</div>
        </div>
        <ProgressBar value={totalSpend} max={totalBudget} height={10} threshold />
        <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 6, fontSize: 10.5, color: COLORS.textMute }}>
          <span>0%</span><span>60% calm</span><span>80% alert</span><span>100%</span>
        </div>

        <div style={{ height: 1, background: COLORS.border, margin: '16px 0 14px' }}/>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          <CategoryRow icon="🍜" tint="#F8326D" name="Food" v={budget.food.spent} m={budget.food.cap}/>
          <CategoryRow icon="🚌" tint="#3B82F6" name="Transport" v={budget.transport.spent} m={budget.transport.cap}/>
          <CategoryRow icon="🛍️" tint="#A855F7" name="Shopping" v={budget.shopping.spent} m={budget.shopping.cap}/>
        </div>
      </GXCard>

      {/* Bill reminder */}
      <GXCard padding={14} style={{ marginBottom: 14, display: 'flex', alignItems: 'center', gap: 12 }}>
        <div style={{
          width: 38, height: 38, borderRadius: 11,
          background: 'linear-gradient(135deg,#3B82F6,#1E40AF)',
          display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 18,
        }}>📱</div>
        <div style={{ flex: 1 }}>
          <div style={{ fontSize: 13.5, fontWeight: 600, color: '#fff' }}>Phone bill RM68</div>
          <div style={{ fontSize: 11.5, color: COLORS.textSoft }}>Due in 2 days · auto-paid from main</div>
        </div>
        <div style={{ fontSize: 11, color: COLORS.textMute }}>10 May</div>
      </GXCard>

      {/* Active alert */}
      {!alertsDismissed && (
        <GXCard accent="rgba(248,50,109,0.4)" padding={16} style={{
          marginBottom: 18,
          background: `linear-gradient(180deg, rgba(248,50,109,0.10) 0%, rgba(255,255,255,0.02) 100%)`,
        }}>
          <div style={{ display: 'flex', gap: 12 }}>
            <div style={{
              width: 36, height: 36, borderRadius: 10, flexShrink: 0,
              background: 'rgba(248,50,109,0.18)', color: '#FF6B95',
              display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 17,
            }}>👀</div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 11, fontWeight: 700, color: '#FF6B95', letterSpacing: '0.1em', textTransform: 'uppercase', marginBottom: 4 }}>Pattern Spotted</div>
              <div style={{ fontSize: 13.5, color: '#fff', lineHeight: 1.45 }}>
                Third food delivery this week. Want to round up RM2 into Emergency Fund?
              </div>
              <div style={{ display: 'flex', gap: 8, marginTop: 12 }}>
                <GXButton size="sm" variant="pink" onClick={() => actions.roundUp(2)}>Round up RM2</GXButton>
                <GXButton size="sm" variant="ghost" onClick={() => actions.dismissAlert()}>Not now</GXButton>
              </div>
            </div>
          </div>
        </GXCard>
      )}

      {/* Quick actions */}
      <SectionHeader title="Demo actions" />
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
        <DemoTriggerButton tint="#F8326D" icon="🍔" label="Spend RM50" sub="Food" onClick={() => actions.spendFood(50)}/>
        <DemoTriggerButton tint="#A855F7" icon="🛍️" label="Spend RM100" sub="Shopping" onClick={() => actions.attemptShopping(100)}/>
        <DemoTriggerButton tint={COLORS.greenLight} icon="💸" label="Receive Salary" sub="RM1,200" onClick={() => actions.receiveSalary()}/>
        <DemoTriggerButton tint="#7C3AED" icon="💎" label="Save RM10" sub="To Emergency" onClick={() => actions.save(10)}/>
      </div>
    </div>
  );
}

function Pill({ icon, label }) {
  return (
    <div style={{
      display: 'inline-flex', alignItems: 'center', gap: 4,
      padding: '4px 9px', borderRadius: 999,
      background: 'rgba(255,255,255,0.07)',
      border: '1px solid rgba(255,255,255,0.10)',
      fontSize: 11, fontWeight: 600, color: '#fff',
    }}>
      <span style={{ fontSize: 12 }}>{icon}</span>{label}
    </div>
  );
}

function CategoryRow({ icon, tint, name, v, m }) {
  const pct = Math.round((v/m)*100);
  return (
    <div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 6 }}>
        <div style={{
          width: 28, height: 28, borderRadius: 8, background: `${tint}22`,
          display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 14,
          border: `1px solid ${tint}44`,
        }}>{icon}</div>
        <div style={{ flex: 1, fontSize: 13.5, fontWeight: 600, color: '#fff' }}>{name}</div>
        <div style={{ fontSize: 12, color: COLORS.textSoft, fontVariantNumeric: 'tabular-nums' }}>RM{v.toFixed(0)} <span style={{ color: COLORS.textMute }}>/ {m}</span></div>
        <div style={{ fontSize: 11.5, fontWeight: 700, color: pct>=99?COLORS.red:pct>=80?COLORS.orange:pct>=60?'#EAB308':COLORS.greenLight, minWidth: 32, textAlign: 'right' }}>{pct}%</div>
      </div>
      <ProgressBar value={v} max={m} height={5} threshold={false} color={pct>=99?COLORS.red:pct>=80?COLORS.orange:pct>=60?'#EAB308':COLORS.greenLight}/>
    </div>
  );
}

function DemoTriggerButton({ tint, icon, label, sub, onClick }) {
  return (
    <button onClick={onClick} style={{
      background: `linear-gradient(135deg, ${tint}22 0%, ${tint}05 100%)`,
      border: `1px solid ${tint}44`,
      borderRadius: 16, padding: '12px 14px', textAlign: 'left',
      cursor: 'pointer', fontFamily: 'inherit',
      color: '#fff', display: 'flex', alignItems: 'center', gap: 10,
      transition: 'transform .12s',
    }}
    onMouseDown={e => e.currentTarget.style.transform = 'scale(0.96)'}
    onMouseUp={e => e.currentTarget.style.transform = 'scale(1)'}
    onMouseLeave={e => e.currentTarget.style.transform = 'scale(1)'}
    >
      <div style={{
        width: 34, height: 34, borderRadius: 10, background: `${tint}33`,
        display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 17,
        border: `1px solid ${tint}55`,
      }}>{icon}</div>
      <div style={{ minWidth: 0 }}>
        <div style={{ fontSize: 12.5, fontWeight: 700 }}>{label}</div>
        <div style={{ fontSize: 10.5, color: COLORS.textSoft, marginTop: 1 }}>{sub}</div>
      </div>
    </button>
  );
}

// ────────────────────────────────────────────────────────
// Spend
// ────────────────────────────────────────────────────────
function SpendScreen({ state }) {
  const { transactions, weeklyTotal } = state;
  return (
    <div style={{ padding: '8px 18px 130px' }}>
      <div style={{ marginBottom: 16 }}>
        <div style={{ fontSize: 13, color: COLORS.textSoft, marginBottom: 2 }}>This week</div>
        <div style={{ fontSize: 28, fontWeight: 800, color: '#fff', letterSpacing: '-0.03em', fontVariantNumeric: 'tabular-nums' }}>
          RM{weeklyTotal.toFixed(2)}
        </div>
        <div style={{ fontSize: 12, color: COLORS.greenLight, marginTop: 2 }}>↓ RM48 vs last week</div>
      </div>

      <GXCard accent="rgba(168,85,247,0.4)" padding={14} style={{ marginBottom: 14, background: 'linear-gradient(180deg,rgba(168,85,247,0.12),rgba(255,255,255,0.02))' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 8 }}>
          <div style={{
            width: 26, height: 26, borderRadius: 7,
            background: 'linear-gradient(135deg,#A855F7,#7C3AED)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none"><path d="M12 2l2.5 6.5L21 11l-6.5 2.5L12 20l-2.5-6.5L3 11l6.5-2.5L12 2z" fill="#fff"/></svg>
          </div>
          <div style={{ fontSize: 11, fontWeight: 700, color: '#C9A8FF', letterSpacing: '0.12em', textTransform: 'uppercase' }}>AI Insight</div>
        </div>
        <div style={{ fontSize: 13.5, color: '#fff', lineHeight: 1.45 }}>
          Food spending is <b style={{ color: '#FF8FB1' }}>178% higher</b> than your usual weekly average. Most happens after 8pm — try a Pause Tonight rule?
        </div>
      </GXCard>

      <div style={{ display: 'flex', gap: 8, marginBottom: 14, overflowX: 'auto', paddingBottom: 4 }}>
        {['All', 'Risky', 'Essential', 'Income', 'Food', 'Transport'].map((f, i) => (
          <div key={f} style={{
            padding: '6px 12px', borderRadius: 999, fontSize: 12, fontWeight: 600,
            background: i === 0 ? COLORS.violet : 'rgba(255,255,255,0.05)',
            color: '#fff', border: i === 0 ? 'none' : '1px solid rgba(255,255,255,0.08)',
            whiteSpace: 'nowrap', flexShrink: 0,
          }}>{f}</div>
        ))}
      </div>

      <SectionHeader title="Recent activity" />
      <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
        {transactions.map((tx, i) => <TransactionItem key={i} tx={tx}/>)}
      </div>
    </div>
  );
}

function TransactionItem({ tx }) {
  const riskColor = tx.risk === 'Risky' ? COLORS.red : tx.risk === 'Unusual' ? COLORS.orange : tx.risk === 'Essential' ? COLORS.greenLight : tx.risk === 'Income' ? COLORS.greenLight : COLORS.textSoft;
  return (
    <GXCard padding={12}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
        <MerchantIcon glyph={tx.glyph} color={tx.color}/>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', gap: 8 }}>
            <div style={{ fontSize: 14, fontWeight: 600, color: '#fff', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{tx.name}</div>
            <div style={{ fontSize: 14, fontWeight: 700, color: tx.income ? COLORS.greenLight : '#fff', fontVariantNumeric: 'tabular-nums', whiteSpace: 'nowrap' }}>
              {tx.income ? '+' : '-'}RM{tx.amount.toFixed(2)}
            </div>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginTop: 3 }}>
            <span style={{ fontSize: 11, color: COLORS.textSoft }}>{tx.time} · {tx.category}</span>
            <span style={{
              padding: '2px 7px', borderRadius: 6, fontSize: 10, fontWeight: 700,
              background: `${riskColor}22`, color: riskColor,
              border: `1px solid ${riskColor}44`,
            }}>{tx.risk}</span>
          </div>
        </div>
      </div>
    </GXCard>
  );
}

// ────────────────────────────────────────────────────────
// Pockets
// ────────────────────────────────────────────────────────
function PocketsScreen({ state, actions, openConfig }) {
  const { pockets, autopilot } = state;
  const total = pockets.reduce((s,p) => s+p.value, 0);
  return (
    <div style={{ padding: '8px 18px 130px' }}>
      <div style={{ marginBottom: 16 }}>
        <div style={{ fontSize: 13, color: COLORS.textSoft, marginBottom: 2 }}>Total saved</div>
        <div style={{ fontSize: 28, fontWeight: 800, color: '#fff', letterSpacing: '-0.03em', fontVariantNumeric: 'tabular-nums' }}>
          RM{total.toFixed(2)}
        </div>
        <div style={{ fontSize: 12, color: COLORS.greenLight, marginTop: 2 }}>↑ RM{(autopilot.lastSplit||0).toFixed(0)} from last salary autopilot</div>
      </div>

      {/* Autopilot card */}
      <GXCard padding={18} style={{ marginBottom: 16, background: `linear-gradient(135deg, ${COLORS.violet}25 0%, rgba(255,255,255,0.02) 100%)`, border: `1px solid ${COLORS.violet}44` }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 10 }}>
          <div style={{
            width: 30, height: 30, borderRadius: 9,
            background: `linear-gradient(135deg, ${COLORS.violet}, #5C12CC)`,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M13 2L3 14h7l-1 8 10-12h-7l1-8z" fill="#fff"/></svg>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 14, fontWeight: 700, color: '#fff' }}>Salary Autopilot</div>
            <div style={{ fontSize: 11.5, color: COLORS.textSoft }}>Active · triggers above RM{autopilot.threshold}</div>
          </div>
          <div style={{
            width: 38, height: 22, borderRadius: 999, background: COLORS.violet,
            position: 'relative', boxShadow: `0 0 12px ${COLORS.violet}88`,
          }}>
            <div style={{ position: 'absolute', top: 2, right: 2, width: 18, height: 18, borderRadius: '50%', background: '#fff' }}/>
          </div>
        </div>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 8, marginBottom: 12 }}>
          <SplitChip pct={20} label="Emergency" color="#1FB287"/>
          <SplitChip pct={10} label="PTPTN" color="#3B82F6"/>
          <SplitChip pct={5} label="Travel" color="#F8326D"/>
        </div>
        <GXButton variant="soft" full onClick={openConfig}>Configure Autopilot</GXButton>
      </GXCard>

      <SectionHeader title="Your pockets" action="+ New" />
      <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
        {pockets.map((p, i) => <PocketCard key={i} p={p}/>)}
      </div>
    </div>
  );
}

function SplitChip({ pct, label, color }) {
  return (
    <div style={{
      padding: '10px 8px', borderRadius: 12,
      background: `${color}1a`, border: `1px solid ${color}44`,
      textAlign: 'center',
    }}>
      <div style={{ fontSize: 16, fontWeight: 800, color, letterSpacing: '-0.02em' }}>{pct}%</div>
      <div style={{ fontSize: 10, color: COLORS.textSoft, marginTop: 1 }}>{label}</div>
    </div>
  );
}

function PocketCard({ p }) {
  const pct = Math.round((p.value/p.goal)*100);
  return (
    <GXCard padding={16}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 10 }}>
        <div style={{
          width: 44, height: 44, borderRadius: 12,
          background: `linear-gradient(135deg, ${p.color} 0%, ${p.color}cc 100%)`,
          display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 22,
          boxShadow: `0 6px 16px ${p.color}55`,
        }}>{p.icon}</div>
        <div style={{ flex: 1 }}>
          <div style={{ fontSize: 14.5, fontWeight: 700, color: '#fff' }}>{p.name}</div>
          <div style={{ fontSize: 11.5, color: COLORS.textSoft }}>{p.note}</div>
        </div>
        <div style={{ textAlign: 'right' }}>
          <div style={{ fontSize: 15, fontWeight: 800, color: '#fff', fontVariantNumeric: 'tabular-nums' }}>RM{p.value}</div>
          <div style={{ fontSize: 10.5, color: COLORS.textMute, fontVariantNumeric: 'tabular-nums' }}>of RM{p.goal}</div>
        </div>
      </div>
      <ProgressBar value={p.value} max={p.goal} color={p.color} threshold={false} height={6}/>
      <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 6, fontSize: 11, color: COLORS.textMute }}>
        <span>{pct}% complete</span>
        <span>{p.eta}</span>
      </div>
    </GXCard>
  );
}

// ────────────────────────────────────────────────────────
// Squad
// ────────────────────────────────────────────────────────
function SquadScreen({ state, actions, openShield }) {
  const { squad } = state;
  return (
    <div style={{ padding: '8px 18px 130px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end', marginBottom: 16 }}>
        <div>
          <div style={{ fontSize: 13, color: COLORS.textSoft, marginBottom: 2 }}>Your squad</div>
          <div style={{ fontSize: 22, fontWeight: 800, color: '#fff', letterSpacing: '-0.02em' }}>{squad.name}</div>
        </div>
        <div style={{
          padding: '6px 10px', borderRadius: 999,
          background: 'rgba(255,255,255,0.06)',
          border: '1px solid rgba(255,255,255,0.1)',
          fontSize: 11.5, fontWeight: 600, color: '#fff',
        }}>4 members</div>
      </div>

      {/* Goal */}
      <GXCard padding={18} style={{ marginBottom: 14, background: `linear-gradient(135deg, ${COLORS.pink}22, rgba(255,255,255,0.02))`, border: `1px solid ${COLORS.pink}44` }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 12 }}>
          <div>
            <div style={{ fontSize: 11, color: '#FF8FB1', letterSpacing: '0.1em', textTransform: 'uppercase', fontWeight: 700, marginBottom: 4 }}>Shared Goal</div>
            <div style={{ fontSize: 16, fontWeight: 700, color: '#fff' }}>Save RM500 in 30 days</div>
          </div>
          <div style={{ fontSize: 22, fontWeight: 800, color: '#fff', fontVariantNumeric: 'tabular-nums' }}>{squad.progress}%</div>
        </div>
        <ProgressBar value={squad.progress} max={100} color={COLORS.pink} threshold={false} height={9}/>
        <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 8, fontSize: 11, color: COLORS.textSoft }}>
          <span>RM320 of RM500</span><span>14 days left</span>
        </div>
      </GXCard>

      {/* AI insight */}
      <GXCard padding={14} accent={`${COLORS.violet}55`} style={{ marginBottom: 14, background: `linear-gradient(180deg, ${COLORS.violet}18, rgba(255,255,255,0.02))` }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 6 }}>
          <span style={{ fontSize: 13 }}>🤖</span>
          <div style={{ fontSize: 11, fontWeight: 700, color: '#C9A8FF', letterSpacing: '0.1em', textTransform: 'uppercase' }}>Weekly squad insight</div>
        </div>
        <div style={{ fontSize: 13.5, color: '#fff', lineHeight: 1.45 }}>
          You're on track, but <b>Kumar</b> may need a nudge to maintain the streak.
        </div>
        <div style={{ marginTop: 10, display: 'flex', gap: 8 }}>
          <GXButton size="sm" variant="primary" onClick={openShield}>Send Hold Strong 💪</GXButton>
          <GXButton size="sm" variant="ghost">Invite Friends</GXButton>
        </div>
      </GXCard>

      <SectionHeader title="Members" />
      <div style={{ display: 'flex', flexDirection: 'column', gap: 8, marginBottom: 14 }}>
        {squad.members.map((m, i) => <SquadMemberCard key={i} m={m}/>)}
      </div>

      {/* Reward */}
      <GXCard padding={16} style={{ background: `linear-gradient(135deg, #7C3AED22 0%, #F8326D22 100%)`, border: '1px solid rgba(124,58,237,0.4)' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <div style={{ fontSize: 32 }}>🏆</div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 13.5, fontWeight: 700, color: '#fff' }}>Hit a 30-day streak</div>
            <div style={{ fontSize: 11.5, color: COLORS.textSoft }}>Unlock vouchers & GX rewards</div>
          </div>
          <div style={{ fontSize: 11, fontWeight: 700, color: '#FFD700' }}>+200 pts</div>
        </div>
      </GXCard>
    </div>
  );
}

function SquadMemberCard({ m }) {
  return (
    <GXCard padding={12}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
        <div style={{
          width: 40, height: 40, borderRadius: '50%',
          background: `linear-gradient(135deg, ${m.color}, ${m.color}aa)`,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontSize: 14, fontWeight: 800, color: '#fff',
          border: `2px solid ${m.color}55`,
        }}>{m.initials}</div>
        <div style={{ flex: 1 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
            <div style={{ fontSize: 14, fontWeight: 600, color: '#fff' }}>{m.name}{m.you && <span style={{ fontSize: 10, color: COLORS.textMute, marginLeft: 6 }}>· you</span>}</div>
            <div style={{ fontSize: 13, fontWeight: 700, color: '#fff', fontVariantNumeric: 'tabular-nums' }}>{m.progress}%</div>
          </div>
          <div style={{ marginTop: 5 }}>
            <ProgressBar value={m.progress} max={100} color={m.color} threshold={false} height={4}/>
          </div>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 5, fontSize: 11, color: COLORS.textMute }}>
            <span>🔥 {m.streak}-day streak</span>
            <span>{m.status}</span>
          </div>
        </div>
      </div>
    </GXCard>
  );
}

// ────────────────────────────────────────────────────────
// Profile
// ────────────────────────────────────────────────────────
function ProfileScreen({ state, actions }) {
  return (
    <div style={{ padding: '8px 18px 130px' }}>
      <GXCard padding={18} style={{ marginBottom: 16, textAlign: 'center' }}>
        <div style={{
          width: 78, height: 78, borderRadius: '50%', margin: '0 auto 12px',
          background: `linear-gradient(135deg, ${COLORS.violet}, ${COLORS.pink})`,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontSize: 28, fontWeight: 800, color: '#fff',
          boxShadow: `0 10px 30px ${COLORS.violet}55`,
        }}>A</div>
        <div style={{ fontSize: 19, fontWeight: 800, color: '#fff', letterSpacing: '-0.02em' }}>Aiman</div>
        <div style={{ fontSize: 12.5, color: COLORS.textSoft, marginTop: 2 }}>Level 4 saver · 8 day streak 🔥</div>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 1, marginTop: 16, background: COLORS.border, borderRadius: 14, overflow: 'hidden' }}>
          {[
            { v: 'RM1,200', l: 'Income/mo' },
            { v: 'RM800', l: 'Threshold' },
            { v: '8', l: 'Streak' },
          ].map((s,i) => (
            <div key={i} style={{ padding: '10px 6px', background: 'rgba(20,5,55,0.7)' }}>
              <div style={{ fontSize: 14, fontWeight: 700, color: '#fff' }}>{s.v}</div>
              <div style={{ fontSize: 10.5, color: COLORS.textMute, marginTop: 1 }}>{s.l}</div>
            </div>
          ))}
        </div>
      </GXCard>

      <ProfileSection title="Notifications">
        <SettingRow icon="📲" label="Push notifications" toggle={state.toggles.push} onToggle={() => actions.toggle('push')}/>
        <SettingRow icon="💬" label="WhatsApp alerts" toggle={state.toggles.whatsapp} onToggle={() => actions.toggle('whatsapp')}/>
        <SettingRow icon="✈️" label="Telegram alerts" toggle={state.toggles.telegram} onToggle={() => actions.toggle('telegram')}/>
      </ProfileSection>

      <ProfileSection title="Privacy">
        <SettingRow icon="🕶️" label="Anonymous squad progress" sub="Hide your name in shared goals" toggle={state.toggles.anon} onToggle={() => actions.toggle('anon')}/>
        <SettingRow icon="👁️" label="Hide exact balances" sub="Show % only on social cards" toggle={state.toggles.hideBalance} onToggle={() => actions.toggle('hideBalance')}/>
      </ProfileSection>

      <ProfileSection title="Security">
        <SettingRow icon="🧊" label="Freeze card" chevron danger/>
        <SettingRow icon="📉" label="Spending limit" chevron right="RM400/wk"/>
        <SettingRow icon="🚨" label="Scam alert support" chevron/>
      </ProfileSection>
    </div>
  );
}

function ProfileSection({ title, children }) {
  return (
    <div style={{ marginBottom: 16 }}>
      <div style={{ fontSize: 11, fontWeight: 700, color: COLORS.textSoft, letterSpacing: '0.12em', textTransform: 'uppercase', marginBottom: 8, paddingLeft: 4 }}>{title}</div>
      <GXCard padding={4}>
        {children}
      </GXCard>
    </div>
  );
}

function SettingRow({ icon, label, sub, toggle, onToggle, chevron, right, danger }) {
  return (
    <div onClick={onToggle} style={{
      display: 'flex', alignItems: 'center', gap: 12,
      padding: '12px 12px',
      borderBottom: `1px solid ${COLORS.border}`,
      cursor: onToggle || chevron ? 'pointer' : 'default',
    }}>
      <div style={{
        width: 32, height: 32, borderRadius: 9,
        background: 'rgba(255,255,255,0.06)',
        display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 15,
      }}>{icon}</div>
      <div style={{ flex: 1 }}>
        <div style={{ fontSize: 13.5, color: danger ? '#FF8A8A' : '#fff', fontWeight: 600 }}>{label}</div>
        {sub && <div style={{ fontSize: 11, color: COLORS.textMute, marginTop: 1 }}>{sub}</div>}
      </div>
      {right && <div style={{ fontSize: 12, color: COLORS.textSoft, marginRight: 4 }}>{right}</div>}
      {toggle !== undefined && (
        <div style={{
          width: 38, height: 22, borderRadius: 999,
          background: toggle ? COLORS.violet : 'rgba(255,255,255,0.12)',
          position: 'relative', transition: 'background .25s',
          boxShadow: toggle ? `0 0 12px ${COLORS.violet}66` : 'none',
        }}>
          <div style={{
            position: 'absolute', top: 2, left: toggle ? 18 : 2,
            width: 18, height: 18, borderRadius: '50%', background: '#fff',
            transition: 'left .25s',
          }}/>
        </div>
      )}
      {chevron && <span style={{ color: COLORS.textMute, fontSize: 16 }}>›</span>}
    </div>
  );
}

Object.assign(window, { HomeScreen, SpendScreen, PocketsScreen, SquadScreen, ProfileScreen });
