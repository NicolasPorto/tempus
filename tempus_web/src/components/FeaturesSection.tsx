import { type ReactNode } from 'react'
import RevealWrapper from './RevealWrapper'

function TimerIcon() {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <defs>
        <linearGradient id="timerGrad" x1="3" y1="3" x2="21" y2="21" gradientUnits="userSpaceOnUse">
          <stop stopColor="#AC46FF" />
          <stop offset="1" stopColor="#2B7FFF" />
        </linearGradient>
      </defs>
      <circle cx="12" cy="12" r="9" stroke="url(#timerGrad)" strokeWidth="1.8" />
      <polyline points="12 7 12 12 15 15" stroke="url(#timerGrad)" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  )
}

function TasksIcon() {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <defs>
        <linearGradient id="tasksGrad" x1="3" y1="3" x2="21" y2="21" gradientUnits="userSpaceOnUse">
          <stop stopColor="#00C850" />
          <stop offset="1" stopColor="#00BC7C" />
        </linearGradient>
      </defs>
      <rect x="3" y="3" width="18" height="18" rx="3" stroke="url(#tasksGrad)" strokeWidth="1.8" />
      <polyline points="7.5 12 10.5 15 16.5 9" stroke="url(#tasksGrad)" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  )
}

function StatsIcon() {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <defs>
        <linearGradient id="statsGrad" x1="2" y1="4" x2="20" y2="21" gradientUnits="userSpaceOnUse">
          <stop stopColor="#FF6800" />
          <stop offset="1" stopColor="#FD9900" />
        </linearGradient>
      </defs>
      <rect x="2" y="13" width="4" height="8" rx="1" fill="url(#statsGrad)" />
      <rect x="9" y="9" width="4" height="12" rx="1" fill="url(#statsGrad)" />
      <rect x="16" y="4" width="4" height="17" rx="1" fill="url(#statsGrad)" />
    </svg>
  )
}

interface FeatureCardProps {
  title: string
  description: string
  icon: ReactNode
  barColors: [string, string]
  iconBg: string
}

function FeatureCard({ title, description, icon, barColors, iconBg }: FeatureCardProps) {
  return (
    <div
      className="feature-card"
      style={{
        background: 'rgba(18, 14, 28, 0.7)',
        border: '1px solid rgba(255, 255, 255, 0.07)',
        borderRadius: 18,
        overflow: 'hidden',
        display: 'flex',
        flexDirection: 'column',
        height: '100%',
      }}
    >
      {/* Top gradient bar */}
      <div
        style={{
          height: 3,
          background: `linear-gradient(to right, ${barColors[0]}, ${barColors[1]})`,
        }}
      />

      <div style={{ padding: '26px 24px' }}>
        {/* Icon */}
        <div
          style={{
            width: 50,
            height: 50,
            borderRadius: 14,
            background: iconBg,
            border: '1px solid rgba(255,255,255,0.06)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            marginBottom: 18,
          }}
        >
          {icon}
        </div>

        <h3
          style={{
            fontSize: 17,
            fontWeight: 700,
            color: '#F0F0F0',
            margin: '0 0 10px',
            letterSpacing: '-0.3px',
          }}
        >
          {title}
        </h3>

        <p
          style={{
            fontSize: 14,
            color: '#707070',
            lineHeight: 1.7,
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
      icon: <TimerIcon />,
      barColors: ['#AC46FF', '#2B7FFF'],
      iconBg: 'rgba(172, 70, 255, 0.1)',
    },
    {
      title: 'Gerenciamento de Tarefas',
      description:
        'Crie tarefas por matéria com metas em minutos. Marque como concluídas ao longo do dia e acompanhe seu progresso em tempo real.',
      icon: <TasksIcon />,
      barColors: ['#00C850', '#00BC7C'],
      iconBg: 'rgba(0, 200, 80, 0.1)',
    },
    {
      title: 'Estatísticas Detalhadas',
      description:
        'Acompanhe o tempo total estudado, sessões finalizadas, sua sequência diária (streak) e quantas tarefas você concluiu.',
      icon: <StatsIcon />,
      barColors: ['#FF6800', '#FD9900'],
      iconBg: 'rgba(255, 104, 0, 0.1)',
    },
  ]

  return (
    <section
      id="funcionalidades"
      style={{
        position: 'relative',
        zIndex: 1,
        padding: '80px 16px',
        maxWidth: 1100,
        margin: '0 auto',
      }}
    >
      {/* Section header */}
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
          ✦ Funcionalidades
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
          Tudo que você precisa para{' '}
          <span className="gradient-text">estudar melhor</span>
        </h2>
        <p style={{ fontSize: 16, color: '#606060', margin: 0, maxWidth: 480, marginInline: 'auto' }}>
          Funcionalidades projetadas para maximizar seu foco e produtividade
        </p>
      </RevealWrapper>

      {/* Cards grid */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))',
          gap: 20,
        }}
      >
        {features.map((f, i) => (
          <RevealWrapper key={f.title} delay={i * 130} style={{ height: '100%' }}>
            <FeatureCard {...f} />
          </RevealWrapper>
        ))}
      </div>
    </section>
  )
}
