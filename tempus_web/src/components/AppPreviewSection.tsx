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
                <span style={{ fontSize: 8, color: 'white', lineHeight: 1 }}>✓</span>
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

export default function AppPreviewSection() {
  const highlights = [
    { icon: '🎯', text: 'Modo imersivo escurece a tela no foco' },
    { icon: '🔔', text: 'Alertas sonoros e vibração discretos' },
    { icon: '📈', text: 'Dashboard de progresso simplificado' },
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
              padding: '4px 12px',
              background: 'rgba(172, 70, 255, 0.1)',
              border: '1px solid rgba(172, 70, 255, 0.25)',
              borderRadius: 100,
              fontSize: 12,
              color: '#AC46FF',
              fontWeight: 600,
              marginBottom: 20,
              letterSpacing: 0.3,
            }}
          >
            ✦ Interface intuitiva
          </div>

          <h2
            style={{
              fontSize: 'clamp(28px, 4.5vw, 42px)',
              fontWeight: 700,
              color: '#F4F4F4',
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
              color: '#A0A0A0',
              lineHeight: 1.75,
              margin: '0 0 28px',
            }}
          >
            Interface minimalista que mantém seu foco no que importa. Sem menus
            complexos — só você e seu objetivo.
          </p>

          <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
            {highlights.map(item => (
              <div key={item.text} style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                <span style={{ fontSize: 18, flexShrink: 0 }}>{item.icon}</span>
                <span style={{ fontSize: 14, color: '#C0C0C0', lineHeight: 1.4 }}>{item.text}</span>
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
