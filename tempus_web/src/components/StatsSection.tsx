import RevealWrapper from './RevealWrapper'

const stats = [
  { value: '10K+', label: 'Downloads' },
  { value: '200K+', label: 'Sessões completadas' },
  { value: '4.9★', label: 'Avaliação na loja' },
]

export default function StatsSection() {
  return (
    <section
      style={{
        position: 'relative',
        zIndex: 1,
        padding: '0 16px 72px',
        maxWidth: 860,
        margin: '0 auto',
      }}
    >
      <RevealWrapper delay={0}>
        <div
          style={{
            display: 'flex',
            background: 'rgba(20, 16, 32, 0.6)',
            border: '1px solid rgba(255,255,255,0.08)',
            borderRadius: 20,
            overflow: 'hidden',
          }}
        >
          {stats.map((stat, i) => (
            <div
              key={stat.label}
              style={{
                flex: 1,
                textAlign: 'center',
                padding: 'clamp(20px, 3vw, 32px) 16px',
                borderRight: i < stats.length - 1 ? '1px solid rgba(255,255,255,0.07)' : 'none',
              }}
            >
              <div
                className="gradient-text"
                style={{
                  fontSize: 'clamp(22px, 4vw, 34px)',
                  fontWeight: 700,
                  letterSpacing: '-1px',
                  lineHeight: 1,
                }}
              >
                {stat.value}
              </div>
              <div
                style={{
                  fontSize: 12,
                  color: '#5A5A5A',
                  marginTop: 6,
                  fontWeight: 500,
                  letterSpacing: 0.2,
                }}
              >
                {stat.label}
              </div>
            </div>
          ))}
        </div>
      </RevealWrapper>
    </section>
  )
}
