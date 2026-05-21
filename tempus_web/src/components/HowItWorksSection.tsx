interface StepProps {
  number: string
  title: string
  description: string
  isLast?: boolean
}

function Step({ number, title, description, isLast }: StepProps) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center', flex: 1 }}>
      {/* Number circle */}
      <div
        style={{
          width: 64,
          height: 64,
          borderRadius: '50%',
          background: 'linear-gradient(135deg, #AC46FF, #2B7FFF)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          fontSize: 24,
          fontWeight: 700,
          color: 'white',
          marginBottom: 20,
          flexShrink: 0,
          boxShadow: '0 8px 24px rgba(172, 70, 255, 0.3)',
        }}
      >
        {number}
      </div>

      <h3 style={{ fontSize: 20, fontWeight: 700, color: '#F4F4F4', margin: '0 0 10px' }}>
        {title}
      </h3>
      <p style={{ fontSize: 14, color: '#A0A0A0', lineHeight: 1.65, margin: 0, maxWidth: 220 }}>
        {description}
      </p>
    </div>
  )
}

function Arrow() {
  return (
    <div
      style={{
        color: 'rgba(172, 70, 255, 0.4)',
        fontSize: 24,
        padding: '0 8px',
        alignSelf: 'flex-start',
        marginTop: 20,
        flexShrink: 0,
      }}
    >
      →
    </div>
  )
}

export default function HowItWorksSection() {
  return (
    <section
      style={{
        position: 'relative',
        zIndex: 1,
        padding: '80px 16px',
        maxWidth: 900,
        margin: '0 auto',
      }}
    >
      {/* Section header */}
      <div style={{ textAlign: 'center', marginBottom: 64 }}>
        <h2
          style={{
            fontSize: 'clamp(28px, 5vw, 40px)',
            fontWeight: 700,
            color: '#F4F4F4',
            margin: '0 0 12px',
          }}
        >
          Como <span className="gradient-text">funciona</span>
        </h2>
        <p style={{ fontSize: 16, color: '#A0A0A0', margin: 0 }}>
          Três passos simples para uma sessão de foco produtiva
        </p>
      </div>

      {/* Steps */}
      <div
        style={{
          display: 'flex',
          alignItems: 'flex-start',
          gap: 8,
          flexWrap: 'wrap',
          justifyContent: 'center',
        }}
      >
        <Step
          number="1"
          title="Selecione"
          description="Escolha a matéria e defina o tempo de foco: 15, 20, 25 ou 30 minutos"
        />
        <Arrow />
        <Step
          number="2"
          title="Foque"
          description="O timer conta regressivamente enquanto a tela escurece automaticamente para eliminar distrações"
        />
        <Arrow />
        <Step
          number="3"
          title="Revise"
          description="Analise suas estatísticas, mantenha sua sequência diária e veja seu progresso crescer"
          isLast
        />
      </div>

      {/* Bottom CTA card */}
      <div
        className="glass-card"
        style={{
          marginTop: 72,
          padding: '36px 32px',
          textAlign: 'center',
        }}
      >
        <p
          style={{
            fontSize: 22,
            fontWeight: 700,
            color: '#F4F4F4',
            margin: '0 0 8px',
          }}
        >
          Pronto para estudar com mais foco?
        </p>
        <p style={{ fontSize: 14, color: '#A0A0A0', margin: '0 0 24px' }}>
          Gratuito. Sem anúncios intrusivos. Feito para estudantes.
        </p>
        <button
          className="btn-gradient"
          style={{ padding: '14px 36px', fontSize: 16 }}
        >
          Baixar o Tempus
        </button>
      </div>
    </section>
  )
}
