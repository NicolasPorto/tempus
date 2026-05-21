interface FeatureCardProps {
  title: string
  description: string
  icon: string
  barColors: [string, string]
  iconBg: string
}

function FeatureCard({ title, description, icon, barColors, iconBg }: FeatureCardProps) {
  return (
    <div
      style={{
        background: 'rgba(23, 23, 23, 0.66)',
        border: '1px solid rgba(255, 255, 255, 0.08)',
        borderRadius: 16,
        overflow: 'hidden',
        display: 'flex',
        flexDirection: 'column',
      }}
    >
      {/* Top gradient bar */}
      <div
        style={{
          height: 4,
          background: `linear-gradient(to right, ${barColors[0]}, ${barColors[1]})`,
        }}
      />

      <div style={{ padding: '24px' }}>
        {/* Icon */}
        <div
          style={{
            width: 48,
            height: 48,
            borderRadius: 12,
            background: iconBg,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontSize: 22,
            marginBottom: 16,
          }}
        >
          {icon}
        </div>

        <h3
          style={{
            fontSize: 18,
            fontWeight: 700,
            color: '#F4F4F4',
            margin: '0 0 10px',
          }}
        >
          {title}
        </h3>

        <p
          style={{
            fontSize: 14,
            color: '#A0A0A0',
            lineHeight: 1.65,
            margin: 0,
          }}
        >
          {description}
        </p>
      </div>
    </div>
  )
}

export default function FeaturesSection() {
  const features: FeatureCardProps[] = [
    {
      title: 'Timer Pomodoro',
      description:
        'Sessões de foco com presets de 15, 20, 25 e 30 minutos. Alertas sonoros e vibração a cada marco. Modo de foco com escurecimento automático da tela.',
      icon: '⏱',
      barColors: ['#AC46FF', '#2B7FFF'],
      iconBg: 'rgba(172, 70, 255, 0.12)',
    },
    {
      title: 'Gerenciamento de Tarefas',
      description:
        'Crie tarefas por matéria com metas em minutos. Marque como concluídas ao longo do dia e acompanhe seu progresso em tempo real.',
      icon: '✓',
      barColors: ['#00C850', '#00BC7C'],
      iconBg: 'rgba(0, 200, 80, 0.12)',
    },
    {
      title: 'Estatísticas Detalhadas',
      description:
        'Acompanhe o tempo total estudado, sessões finalizadas, sua sequência diária (streak) e quantas tarefas você concluiu.',
      icon: '📊',
      barColors: ['#FF6800', '#FD9900'],
      iconBg: 'rgba(255, 104, 0, 0.12)',
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
      {/* Section header */}
      <div style={{ textAlign: 'center', marginBottom: 56 }}>
        <h2
          style={{
            fontSize: 'clamp(28px, 5vw, 40px)',
            fontWeight: 700,
            color: '#F4F4F4',
            margin: '0 0 12px',
          }}
        >
          Tudo que você precisa para{' '}
          <span className="gradient-text">estudar melhor</span>
        </h2>
        <p style={{ fontSize: 16, color: '#A0A0A0', margin: 0 }}>
          Funcionalidades projetadas para maximizar seu foco e produtividade
        </p>
      </div>

      {/* Cards grid */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))',
          gap: 20,
        }}
      >
        {features.map(f => (
          <FeatureCard key={f.title} {...f} />
        ))}
      </div>
    </section>
  )
}
