import RevealWrapper from './RevealWrapper'

export default function Footer() {
  const scrollTo = (id: string) => {
    document.getElementById(id)?.scrollIntoView({ behavior: 'smooth' })
  }

  return (
    <footer
      style={{
        position: 'relative',
        zIndex: 1,
        borderTop: '1px solid rgba(255, 255, 255, 0.07)',
        padding: '56px 16px 32px',
      }}
    >
      <RevealWrapper delay={0}>
        <div
          style={{
            maxWidth: 960,
            margin: '0 auto 40px',
            display: 'flex',
            gap: 40,
            flexWrap: 'wrap',
            justifyContent: 'space-between',
            alignItems: 'flex-start',
          }}
        >
          {/* Brand */}
          <div style={{ maxWidth: 260 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 12 }}>
              <span style={{ fontSize: 22 }}>⏱</span>
              <span
                className="gradient-text"
                style={{ fontSize: 22, fontWeight: 700, letterSpacing: '-0.5px' }}
              >
                Tempus
              </span>
            </div>
            <p style={{ fontSize: 13, color: '#5A5A5A', margin: 0, lineHeight: 1.7 }}>
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
                color: '#3A3A3A',
                fontWeight: 700,
                letterSpacing: 1.2,
                marginBottom: 16,
              }}
            >
              NAVEGAÇÃO
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 11 }}>
              {[
                { label: 'Funcionalidades', id: 'funcionalidades' },
                { label: 'Como funciona', id: 'como-funciona' },
                { label: 'Baixar o App', id: 'como-funciona' },
              ].map(({ label, id }) => (
                <button
                  key={label}
                  onClick={() => scrollTo(id)}
                  style={{
                    background: 'none',
                    border: 'none',
                    cursor: 'pointer',
                    fontSize: 13,
                    color: '#5A5A5A',
                    padding: 0,
                    textAlign: 'left',
                    transition: 'color 0.2s',
                  }}
                  onMouseEnter={e => (e.currentTarget.style.color = '#D4D4D4')}
                  onMouseLeave={e => (e.currentTarget.style.color = '#5A5A5A')}
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
                color: '#3A3A3A',
                fontWeight: 700,
                letterSpacing: 1.2,
                marginBottom: 16,
              }}
            >
              DISPONÍVEL EM
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
              {[
                { icon: '🤖', label: 'Android', sub: 'Google Play' },
                { icon: '🍎', label: 'iOS', sub: 'App Store' },
              ].map(({ icon, label, sub }) => (
                <div key={label} style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                  <span style={{ fontSize: 20 }}>{icon}</span>
                  <div>
                    <div style={{ fontSize: 13, color: '#A0A0A0', fontWeight: 600, lineHeight: 1 }}>
                      {label}
                    </div>
                    <div style={{ fontSize: 11, color: '#3A3A3A', marginTop: 2 }}>{sub}</div>
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
          <p style={{ fontSize: 12, color: '#3A3A3A', margin: 0 }}>
            © {new Date().getFullYear()} Tempus. Todos os direitos reservados.
          </p>
          <p style={{ fontSize: 12, color: '#3A3A3A', margin: 0 }}>
            Feito com ♥ para estudantes brasileiros
          </p>
        </div>
      </RevealWrapper>
    </footer>
  )
}
