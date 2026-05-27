import RevealWrapper from './RevealWrapper'

function AndroidIcon() {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
      <path d="M6 18c0 .55.45 1 1 1h1v3.5c0 .83.67 1.5 1.5 1.5S11 23.33 11 22.5V19h2v3.5c0 .83.67 1.5 1.5 1.5s1.5-.67 1.5-1.5V19h1c.55 0 1-.45 1-1V8H6v10zm-2.5-1C2.67 17 2 17.67 2 18.5v5c0 .83.67 1.5 1.5 1.5S5 24.33 5 23.5v-5C5 17.67 4.33 17 3.5 17zm17 0c-.83 0-1.5.67-1.5 1.5v5c0 .83.67 1.5 1.5 1.5s1.5-.67 1.5-1.5v-5c0-.83-.67-1.5-1.5-1.5zM15.53 2.16l1.3-1.3c.2-.2.2-.51 0-.71-.2-.2-.51-.2-.71 0l-1.48 1.48A5.84 5.84 0 0 0 12 1c-.96 0-1.86.23-2.66.63L7.88.15c-.2-.2-.51-.2-.71 0-.2.2-.2.51 0 .71l1.31 1.31C7.05 3.07 6 5.01 6 7h12c0-1.99-.97-3.75-2.47-4.84zM10 5H9V4h1v1zm5 0h-1V4h1v1z" />
    </svg>
  )
}

function AppleIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
      <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" />
    </svg>
  )
}

export default function HeroSection() {
  return (
    <section
      id="inicio"
      style={{
        position: 'relative',
        zIndex: 1,
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '88px 16px 24px',
      }}
    >
      <div style={{ maxWidth: '520px', width: '100%', textAlign: 'center' }}>
        {/* Logo icon */}
        <RevealWrapper delay={100} style={{ display: 'flex', justifyContent: 'center' }}>
          <div
            style={{
              width: 96,
              height: 96,
              marginBottom: 32,
              background: 'radial-gradient(circle at 40% 40%, rgba(172,70,255,0.18), rgba(43,127,255,0.10))',
              border: '1.5px solid rgba(172,70,255,0.25)',
              borderRadius: 26,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              position: 'relative',
            }}
          >
            {/* Outer ring */}
            <div
              style={{
                position: 'absolute',
                inset: -10,
                borderRadius: 36,
                border: '1px solid rgba(172, 70, 255, 0.1)',
                pointerEvents: 'none',
              }}
            />
            <img
              src="/icon_login.svg"
              alt="Tempus"
              width={64}
              height={64}
              className="logo-glow hero-logo-enter"
              style={{ display: 'block' }}
            />
          </div>
        </RevealWrapper>

        {/* Title */}
        <RevealWrapper delay={200}>
          <h1
            className="gradient-text"
            style={{
              fontSize: 'clamp(52px, 9vw, 80px)',
              fontWeight: 700,
              margin: '0 0 18px',
              letterSpacing: '-3px',
              lineHeight: 1,
            }}
          >
            Tempus
          </h1>
        </RevealWrapper>

        {/* Tagline */}
        <RevealWrapper delay={320}>
          <p
            style={{
              fontSize: 'clamp(18px, 3vw, 22px)',
              color: '#D4D4D4',
              margin: '0 0 14px',
              fontWeight: 600,
              letterSpacing: '-0.3px',
            }}
          >
            Organize seus estudos com o método Pomodoro
          </p>
        </RevealWrapper>

        {/* Description */}
        <RevealWrapper delay={420}>
          <p
            style={{
              fontSize: 15,
              color: '#707070',
              margin: '0 0 44px',
              lineHeight: 1.7,
            }}
          >
            Timer inteligente, gerenciamento de tarefas e estatísticas detalhadas.
            <br />
            Disponível para Android e iOS.
          </p>
        </RevealWrapper>

        {/* CTA Buttons */}
        <RevealWrapper delay={520}>
          <div style={{ display: 'flex', gap: 12, justifyContent: 'center', flexWrap: 'wrap' }}>
            <button
              className="store-badge"
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: 10,
                padding: '12px 22px',
                background: 'rgba(255,255,255,0.05)',
                border: '1px solid rgba(255,255,255,0.12)',
                borderRadius: 14,
                color: '#F4F4F4',
              }}
            >
              <span style={{ color: '#A8D8A8' }}>
                <AndroidIcon />
              </span>
              <div style={{ textAlign: 'left' }}>
                <div style={{ fontSize: 9, color: '#707070', letterSpacing: 0.5, fontWeight: 500 }}>DISPONÍVEL NO</div>
                <div style={{ fontSize: 14, fontWeight: 700, letterSpacing: 0.1 }}>Google Play</div>
              </div>
            </button>

            <button
              className="store-badge"
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: 10,
                padding: '12px 22px',
                background: 'rgba(255,255,255,0.05)',
                border: '1px solid rgba(255,255,255,0.12)',
                borderRadius: 14,
                color: '#F4F4F4',
              }}
            >
              <span style={{ color: '#C8C8C8' }}>
                <AppleIcon />
              </span>
              <div style={{ textAlign: 'left' }}>
                <div style={{ fontSize: 9, color: '#707070', letterSpacing: 0.5, fontWeight: 500 }}>BAIXAR NA</div>
                <div style={{ fontSize: 14, fontWeight: 700, letterSpacing: 0.1 }}>App Store</div>
              </div>
            </button>
          </div>
        </RevealWrapper>

        {/* Pill badge */}
        <RevealWrapper delay={640} style={{ display: 'flex', justifyContent: 'center', marginTop: 44 }}>
          <div
            style={{
              display: 'inline-flex',
              alignItems: 'center',
              gap: 7,
              padding: '7px 16px',
              background: 'rgba(5, 223, 114, 0.07)',
              border: '1px solid rgba(5, 223, 114, 0.2)',
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
                boxShadow: '0 0 6px rgba(5, 223, 114, 0.6)',
              }}
            />
            <span style={{ fontSize: 12, color: '#05DF72', fontWeight: 600, letterSpacing: 0.3 }}>
              Sistema Pomodoro Ativo
            </span>
          </div>
        </RevealWrapper>
      </div>
    </section>
  )
}
