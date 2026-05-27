import RevealWrapper from './RevealWrapper'

function AndroidIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
      <path d="M6 18c0 .55.45 1 1 1h1v3.5c0 .83.67 1.5 1.5 1.5S11 23.33 11 22.5V19h2v3.5c0 .83.67 1.5 1.5 1.5s1.5-.67 1.5-1.5V19h1c.55 0 1-.45 1-1V8H6v10zm-2.5-1C2.67 17 2 17.67 2 18.5v5c0 .83.67 1.5 1.5 1.5S5 24.33 5 23.5v-5C5 17.67 4.33 17 3.5 17zm17 0c-.83 0-1.5.67-1.5 1.5v5c0 .83.67 1.5 1.5 1.5s1.5-.67 1.5-1.5v-5c0-.83-.67-1.5-1.5-1.5zM15.53 2.16l1.3-1.3c.2-.2.2-.51 0-.71-.2-.2-.51-.2-.71 0l-1.48 1.48A5.84 5.84 0 0 0 12 1c-.96 0-1.86.23-2.66.63L7.88.15c-.2-.2-.51-.2-.71 0-.2.2-.2.51 0 .71l1.31 1.31C7.05 3.07 6 5.01 6 7h12c0-1.99-.97-3.75-2.47-4.84zM10 5H9V4h1v1zm5 0h-1V4h1v1z" />
    </svg>
  )
}

function AppleIcon() {
  return (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
      <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" />
    </svg>
  )
}

export default function Footer() {
  const scrollTo = (id: string) => {
    const el = document.getElementById(id)
    if (el) window.scrollTo({ top: el.offsetTop - 80, behavior: 'smooth' })
  }

  return (
    <footer
      style={{
        position: 'relative',
        zIndex: 1,
        borderTop: '1px solid rgba(255, 255, 255, 0.06)',
        padding: '60px 16px 36px',
      }}
    >
      <RevealWrapper delay={0}>
        <div
          style={{
            maxWidth: 960,
            margin: '0 auto 44px',
            display: 'flex',
            gap: 48,
            flexWrap: 'wrap',
            justifyContent: 'space-between',
            alignItems: 'flex-start',
          }}
        >
          {/* Brand */}
          <div style={{ maxWidth: 260 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 14 }}>
              <img
                src="/icon_login.svg"
                alt="Tempus"
                width={26}
                height={26}
                style={{ display: 'block' }}
              />
              <span
                className="gradient-text"
                style={{ fontSize: 20, fontWeight: 700, letterSpacing: '-0.5px' }}
              >
                Tempus
              </span>
            </div>
            <p style={{ fontSize: 13, color: '#686868', margin: 0, lineHeight: 1.8 }}>
              Organize seu tempo.
              <br />
              Conquiste seus objetivos.
              <br />
              Feito para estudantes. Grátis.
            </p>
          </div>

          {/* Navigation links */}
          <div>
            <div
              style={{
                fontSize: 10,
                color: '#585858',
                fontWeight: 700,
                letterSpacing: 1.4,
                marginBottom: 18,
              }}
            >
              NAVEGAÇÃO
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
              {[
                { label: 'Funcionalidades', id: 'funcionalidades' },
                { label: 'Como funciona', id: 'como-funciona' },
                { label: 'Depoimentos', id: 'depoimentos' },
                { label: 'FAQ', id: 'faq' },
              ].map(({ label, id }) => (
                <button
                  key={label}
                  onClick={() => scrollTo(id)}
                  style={{
                    background: 'none',
                    border: 'none',
                    cursor: 'pointer',
                    fontSize: 13,
                    color: '#707070',
                    padding: 0,
                    textAlign: 'left',
                    transition: 'color 0.2s',
                  }}
                  onMouseEnter={e => (e.currentTarget.style.color = '#C0C0C0')}
                  onMouseLeave={e => (e.currentTarget.style.color = '#686868')}
                >
                  {label}
                </button>
              ))}
            </div>
          </div>

          {/* Platforms */}
          <div>
            <div
              style={{
                fontSize: 10,
                color: '#585858',
                fontWeight: 700,
                letterSpacing: 1.4,
                marginBottom: 18,
              }}
            >
              DISPONÍVEL EM
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
              {[
                { icon: <AndroidIcon />, iconColor: '#A8D8A8', label: 'Android', sub: 'Google Play' },
                { icon: <AppleIcon />, iconColor: '#C8C8C8', label: 'iOS', sub: 'App Store' },
              ].map(({ icon, iconColor, label, sub }) => (
                <div key={label} style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                  <div
                    style={{
                      width: 36,
                      height: 36,
                      borderRadius: 10,
                      background: 'rgba(255,255,255,0.03)',
                      border: '1px solid rgba(255,255,255,0.07)',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      color: iconColor,
                    }}
                  >
                    {icon}
                  </div>
                  <div>
                    <div style={{ fontSize: 13, color: '#808080', fontWeight: 600, lineHeight: 1 }}>
                      {label}
                    </div>
                    <div style={{ fontSize: 11, color: '#585858', marginTop: 3 }}>{sub}</div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        <div
          style={{
            maxWidth: 960,
            margin: '0 auto',
            paddingTop: 24,
            borderTop: '1px solid rgba(255,255,255,0.05)',
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            flexWrap: 'wrap',
            gap: 8,
          }}
        >
          <p style={{ fontSize: 12, color: '#585858', margin: 0 }}>
            © {new Date().getFullYear()} Tempus. Todos os direitos reservados.
          </p>
          <p style={{ fontSize: 12, color: '#585858', margin: 0 }}>
            Feito com ♥ para estudantes brasileiros
          </p>
        </div>
      </RevealWrapper>
    </footer>
  )
}
