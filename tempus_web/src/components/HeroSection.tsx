export default function HeroSection() {
  return (
    <section
      style={{
        position: 'relative',
        zIndex: 1,
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '24px 16px',
      }}
    >
      <div style={{ maxWidth: '480px', width: '100%', textAlign: 'center' }}>
        {/* Logo icon */}
        <div
          style={{
            width: 80,
            height: 80,
            margin: '0 auto 28px',
            background: 'linear-gradient(135deg, rgba(172,70,255,0.2), rgba(43,127,255,0.2))',
            border: '2px solid rgba(255,255,255,0.15)',
            borderRadius: 20,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontSize: 36,
          }}
        >
          ⏱
        </div>

        {/* Title */}
        <h1
          className="gradient-text"
          style={{
            fontSize: 'clamp(48px, 8vw, 72px)',
            fontWeight: 700,
            margin: '0 0 16px',
            letterSpacing: '-2px',
          }}
        >
          Tempus
        </h1>

        {/* Tagline */}
        <p
          style={{
            fontSize: 'clamp(18px, 3vw, 22px)',
            color: '#D4D4D4',
            margin: '0 0 12px',
            fontWeight: 600,
          }}
        >
          Organize seus estudos com o método Pomodoro
        </p>

        <p
          style={{
            fontSize: 15,
            color: '#A0A0A0',
            margin: '0 0 40px',
            lineHeight: 1.6,
          }}
        >
          Timer inteligente, gerenciamento de tarefas e estatísticas detalhadas.
          <br />
          Disponível para Android e iOS.
        </p>

        {/* CTA Button */}
        <div style={{ display: 'flex', gap: 12, justifyContent: 'center', flexWrap: 'wrap' }}>
          <button
            className="btn-gradient"
            style={{
              padding: '14px 32px',
              fontSize: 16,
              letterSpacing: 0.3,
            }}
          >
            Baixar o App
          </button>
        </div>

        {/* Pill badge */}
        <div
          style={{
            display: 'inline-flex',
            alignItems: 'center',
            gap: 6,
            marginTop: 40,
            padding: '6px 14px',
            background: 'rgba(5, 223, 114, 0.08)',
            border: '1px solid rgba(5, 223, 114, 0.25)',
            borderRadius: 100,
          }}
        >
          <span
            style={{
              width: 7,
              height: 7,
              borderRadius: '50%',
              background: '#05DF72',
              display: 'inline-block',
            }}
          />
          <span style={{ fontSize: 12, color: '#05DF72', fontWeight: 600 }}>
            Sistema Pomodoro Ativo
          </span>
        </div>
      </div>
    </section>
  )
}
