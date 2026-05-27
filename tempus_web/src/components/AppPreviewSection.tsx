import RevealWrapper from './RevealWrapper'

function PhoneMockup() {
  const tasks = [
    { label: 'Matemática — 30 min', done: true },
    { label: 'Física — 25 min', done: false },
    { label: 'Literatura — 20 min', done: false },
  ]

  return (
    <div
      className="phone-float"
      style={{
        width: 240,
        background: 'linear-gradient(160deg, #12091E, #0C0818)',
        borderRadius: 38,
        border: '1.5px solid rgba(172, 70, 255, 0.3)',
        boxShadow:
          '0 0 60px rgba(172,70,255,0.12), 0 40px 80px rgba(0,0,0,0.55), inset 0 1px 0 rgba(255,255,255,0.07)',
        overflow: 'hidden',
        position: 'relative',
        padding: '46px 18px 24px',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
      }}
    >
      {/* Notch */}
      <div
        style={{
          position: 'absolute',
          top: 15,
          left: '50%',
          transform: 'translateX(-50%)',
          width: 68,
          height: 5,
          borderRadius: 3,
          background: 'rgba(255,255,255,0.1)',
        }}
      />

      {/* Header label */}
      <div style={{ marginBottom: 18, textAlign: 'center' }}>
        <span style={{ fontSize: 10, color: '#5A5A5A', fontWeight: 700, letterSpacing: 1.8 }}>
          TEMPUS
        </span>
      </div>

      {/* Timer ring */}
      <div
        style={{
          width: 138,
          height: 138,
          borderRadius: '50%',
          background: 'conic-gradient(from -90deg, #AC46FF 0deg, #2B7FFF 190deg, rgba(255,255,255,0.05) 190deg)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          marginBottom: 16,
          boxShadow: '0 0 32px rgba(172,70,255,0.18)',
        }}
      >
        <div
          style={{
            width: 112,
            height: 112,
            borderRadius: '50%',
            background: '#0C0818',
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            gap: 3,
          }}
        >
          <span
            style={{
              fontSize: 28,
              fontWeight: 700,
              color: '#F4F4F4',
              letterSpacing: -1,
              lineHeight: 1,
            }}
          >
            25:00
          </span>
          <span style={{ fontSize: 8, color: '#5A5A5A', letterSpacing: 1.5, fontWeight: 700 }}>
            FOCO
          </span>
        </div>
      </div>

      {/* Subject label */}
      <div style={{ fontSize: 11, color: '#AC46FF', fontWeight: 600, marginBottom: 14, letterSpacing: 0.3 }}>
        Matemática
      </div>

      {/* Start button */}
      <button
        style={{
          background: 'linear-gradient(135deg, #AC46FF, #2B7FFF)',
          border: 'none',
          borderRadius: 24,
          padding: '9px 30px',
          color: 'white',
          fontSize: 12,
          fontWeight: 600,
          cursor: 'pointer',
          marginBottom: 22,
          boxShadow: '0 6px 20px rgba(172,70,255,0.28)',
          letterSpacing: 0.3,
        }}
      >
        ▶ Iniciar
      </button>

      {/* Tasks */}
      <div style={{ width: '100%' }}>
        <div
          style={{
            fontSize: 9,
            color: '#3A3A3A',
            fontWeight: 700,
            letterSpacing: 1.2,
            marginBottom: 8,
          }}
        >
          TAREFAS DE HOJE
        </div>
        {tasks.map(task => (
          <div
            key={task.label}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: 8,
              padding: '7px 8px',
              borderRadius: 9,
              background: 'rgba(255,255,255,0.03)',
              marginBottom: 5,
              border: '1px solid rgba(255,255,255,0.05)',
            }}
          >
            <div
              style={{
                width: 15,
                height: 15,
                borderRadius: '50%',
                border: task.done ? 'none' : '1.5px solid rgba(172,70,255,0.4)',
                background: task.done ? 'linear-gradient(135deg, #AC46FF, #2B7FFF)' : 'transparent',
                flexShrink: 0,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              {task.done && (
                <svg width="8" height="8" viewBox="0 0 10 10" fill="none">
                  <polyline points="2 5 4 7 8 3" stroke="white" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
                </svg>
              )}
            </div>
            <span
              style={{
                fontSize: 10,
                color: task.done ? '#3A3A3A' : '#C0C0C0',
                textDecoration: task.done ? 'line-through' : 'none',
              }}
            >
              {task.label}
            </span>
          </div>
        ))}
      </div>
    </div>
  )
}

function FocusIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#AC46FF" strokeWidth="1.8" strokeLinecap="round">
      <circle cx="12" cy="12" r="3" />
      <circle cx="12" cy="12" r="8" />
      <line x1="12" y1="2" x2="12" y2="4" />
      <line x1="12" y1="20" x2="12" y2="22" />
      <line x1="2" y1="12" x2="4" y2="12" />
      <line x1="20" y1="12" x2="22" y2="12" />
    </svg>
  )
}

function BellIcon() {
  return (
    <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="#2B7FFF" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9" />
      <path d="M13.73 21a2 2 0 0 1-3.46 0" />
    </svg>
  )
}

function TrendingIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#FF6800" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <polyline points="23 6 13.5 15.5 8.5 10.5 1 18" />
      <polyline points="17 6 23 6 23 12" />
    </svg>
  )
}

export default function AppPreviewSection() {
  const highlights = [
    {
      icon: <FocusIcon />,
      iconBg: 'rgba(172, 70, 255, 0.1)',
      text: 'Modo imersivo escurece a tela no foco',
    },
    {
      icon: <BellIcon />,
      iconBg: 'rgba(43, 127, 255, 0.1)',
      text: 'Alertas sonoros e vibração discretos',
    },
    {
      icon: <TrendingIcon />,
      iconBg: 'rgba(255, 104, 0, 0.1)',
      text: 'Dashboard de progresso simplificado',
    },
  ]

  return (
    <section
      style={{
        position: 'relative',
        zIndex: 1,
        padding: '80px 16px',
        maxWidth: 1100,
        margin: '0 auto',
      }}
    >
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          gap: 'clamp(40px, 8vw, 100px)',
          flexWrap: 'wrap',
        }}
      >
        {/* Text side */}
        <RevealWrapper delay={0} style={{ maxWidth: 420, flex: '1 1 300px' }}>
          <div
            style={{
              display: 'inline-flex',
              alignItems: 'center',
              gap: 6,
              padding: '5px 14px',
              background: 'rgba(172, 70, 255, 0.08)',
              border: '1px solid rgba(172, 70, 255, 0.2)',
              borderRadius: 100,
              fontSize: 12,
              color: '#AC46FF',
              fontWeight: 600,
              marginBottom: 22,
              letterSpacing: 0.3,
            }}
          >
            ✦ Interface intuitiva
          </div>

          <h2
            style={{
              fontSize: 'clamp(28px, 4.5vw, 42px)',
              fontWeight: 700,
              color: '#F0F0F0',
              margin: '0 0 16px',
              lineHeight: 1.15,
              letterSpacing: '-1px',
            }}
          >
            Desenhado para{' '}
            <span className="gradient-text">não te distrair</span>
          </h2>

          <p
            style={{
              fontSize: 15,
              color: '#606060',
              lineHeight: 1.75,
              margin: '0 0 32px',
            }}
          >
            Interface minimalista que mantém seu foco no que importa. Sem menus
            complexos — só você e seu objetivo.
          </p>

          <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
            {highlights.map(item => (
              <div
                key={item.text}
                className="highlight-item"
                style={{ display: 'flex', alignItems: 'center', gap: 14 }}
              >
                <div
                  style={{
                    width: 38,
                    height: 38,
                    borderRadius: 11,
                    background: item.iconBg,
                    border: '1px solid rgba(255,255,255,0.05)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    flexShrink: 0,
                  }}
                >
                  {item.icon}
                </div>
                <span style={{ fontSize: 14, color: '#B0B0B0', lineHeight: 1.4 }}>{item.text}</span>
              </div>
            ))}
          </div>
        </RevealWrapper>

        {/* Phone side */}
        <RevealWrapper delay={160} style={{ display: 'flex', justifyContent: 'center' }}>
          <PhoneMockup />
        </RevealWrapper>
      </div>
    </section>
  )
}
