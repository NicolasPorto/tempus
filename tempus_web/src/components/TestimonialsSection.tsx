import RevealWrapper from './RevealWrapper'

const testimonials = [
  {
    quote: 'Desde que comecei a usar o Tempus, minha produtividade aumentou muito. O modo foco realmente faz diferença.',
    name: 'Ana Lima',
    role: 'Estudante de Medicina',
    initials: 'AL',
    color: '#AC46FF',
  },
  {
    quote: 'Simples, bonito e funcional. É exatamente o que eu precisava para organizar meus estudos sem distração.',
    name: 'Pedro Souza',
    role: 'Concurseiro',
    initials: 'PS',
    color: '#2B7FFF',
  },
  {
    quote: 'A sequência diária me mantém motivado. Já são 30 dias consecutivos estudando com o Tempus!',
    name: 'Mariana Costa',
    role: 'Estudante de Direito',
    initials: 'MC',
    color: '#00C850',
  },
  {
    quote: 'As estatísticas me ajudam a entender onde estou perdendo tempo. Indispensável para quem estuda sério.',
    name: 'Carlos Mendes',
    role: 'Pré-vestibular',
    initials: 'CM',
    color: '#FF6800',
  },
]

function StarIcon() {
  return (
    <svg width="14" height="14" viewBox="0 0 24 24" fill="#FD9900">
      <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" />
    </svg>
  )
}

export default function TestimonialsSection() {
  return (
    <section
      id="depoimentos"
      style={{
        position: 'relative',
        zIndex: 1,
        padding: '80px 16px',
        maxWidth: 1100,
        margin: '0 auto',
      }}
    >
      <RevealWrapper delay={0} style={{ textAlign: 'center', marginBottom: 60 }}>
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
            marginBottom: 20,
            letterSpacing: 0.3,
          }}
        >
          ✦ Depoimentos
        </div>
        <h2
          style={{
            fontSize: 'clamp(28px, 5vw, 42px)',
            fontWeight: 700,
            color: '#F0F0F0',
            margin: '0 0 14px',
            letterSpacing: '-1px',
          }}
        >
          Quem já usa, <span className="gradient-text">aprova</span>
        </h2>
        <p style={{ fontSize: 16, color: '#606060', margin: 0 }}>
          Mais de 10 mil estudantes já transformaram sua rotina com o Tempus
        </p>
      </RevealWrapper>

      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(260px, 1fr))',
          gap: 20,
        }}
      >
        {testimonials.map((t, i) => (
          <RevealWrapper key={t.name} delay={i * 100} style={{ height: '100%' }}>
            <div
              style={{
                background: 'rgba(18, 14, 28, 0.7)',
                border: '1px solid rgba(255,255,255,0.07)',
                borderRadius: 18,
                padding: '24px',
                display: 'flex',
                flexDirection: 'column',
                gap: 20,
                height: '100%',
              }}
            >
              {/* Stars */}
              <div style={{ display: 'flex', gap: 3 }}>
                {Array.from({ length: 5 }).map((_, j) => <StarIcon key={j} />)}
              </div>

              {/* Quote */}
              <p
                style={{
                  fontSize: 14,
                  color: '#C0C0C0',
                  lineHeight: 1.75,
                  margin: 0,
                  flex: 1,
                }}
              >
                "{t.quote}"
              </p>

              {/* Author */}
              <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                <div
                  style={{
                    width: 40,
                    height: 40,
                    borderRadius: '50%',
                    background: `${t.color}22`,
                    border: `1.5px solid ${t.color}44`,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontSize: 13,
                    fontWeight: 700,
                    color: t.color,
                    flexShrink: 0,
                  }}
                >
                  {t.initials}
                </div>
                <div>
                  <div style={{ fontSize: 13, fontWeight: 600, color: '#E0E0E0' }}>{t.name}</div>
                  <div style={{ fontSize: 11, color: '#585858', marginTop: 2 }}>{t.role}</div>
                </div>
              </div>
            </div>
          </RevealWrapper>
        ))}
      </div>
    </section>
  )
}
