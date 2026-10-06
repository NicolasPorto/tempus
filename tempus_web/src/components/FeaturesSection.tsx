import type { ReactNode } from 'react'
import { Dial, Reveal, SectionHeader } from './ui'

function Card({
  title,
  body,
  children,
  className = '',
  delay = 0,
  tone,
}: {
  title: string
  body: string
  children: ReactNode
  className?: string
  delay?: number
  tone?: string
}) {
  return (
    <Reveal delay={delay} className={className}>
      <article className="group card relative flex h-full flex-col overflow-hidden p-6 transition-all duration-300 hover:-translate-y-1 hover:border-violet/30 sm:p-7">
        {tone && (
          <div
            className="pointer-events-none absolute -right-20 -top-20 h-56 w-56 rounded-full opacity-40 blur-3xl transition-opacity group-hover:opacity-70"
            style={{ background: tone }}
          />
        )}
        <div className="relative mb-6 flex min-h-[150px] flex-1 items-center justify-center">{children}</div>
        <h3 className="relative text-xl font-extrabold tracking-tight">{title}</h3>
        <p className="relative mt-2 leading-relaxed text-sub">{body}</p>
      </article>
    </Reveal>
  )
}

const presets = ['15', '25', '45', '1h', '1h30']

function TasksMini() {
  const rows = [
    { t: 'Lista de integrais', s: 'Cálculo II', m: '45 min', c: '#A855F7' },
    { t: 'Revisar cinemática', s: 'Física', m: '30 min', c: '#60A5FA' },
    { t: 'Reading + resumo', s: 'Inglês', m: '25 min', c: '#34D399' },
  ]
  return (
    <ul className="w-full space-y-2.5">
      {rows.map((r, i) => (
        <li
          key={r.t}
          className="flex items-center gap-3 rounded-2xl border border-line bg-surface-hi/80 p-3"
          style={{ opacity: 1 - i * 0.18 }}
        >
          <span className="h-5 w-5 shrink-0 rounded-full border-2" style={{ borderColor: r.c }} />
          <div className="min-w-0 flex-1">
            <p className="truncate text-sm font-bold">{r.t}</p>
            <p className="mt-0.5 text-xs font-semibold text-sub">
              <span style={{ color: r.c }}>{r.s}</span> · {r.m}
            </p>
          </div>
          <span
            className="grid h-8 w-8 place-items-center rounded-full border"
            style={{ background: `${r.c}22`, borderColor: `${r.c}66`, color: r.c }}
          >
            <svg viewBox="0 0 24 24" className="h-4 w-4" fill="currentColor" aria-hidden="true">
              <path d="M8 5.5v13a1 1 0 0 0 1.5.86l10.8-6.5a1 1 0 0 0 0-1.72L9.5 4.64A1 1 0 0 0 8 5.5z" />
            </svg>
          </span>
        </li>
      ))}
    </ul>
  )
}

function Heatmap() {
  // deterministic pseudo-random pattern
  const cells = Array.from({ length: 12 * 7 }, (_, i) => {
    const v = Math.abs(Math.sin(i * 12.9898) * 43758.5453) % 1
    const recent = i >= 12 * 7 - 12
    return recent ? 2 + Math.round(v * 2) : v < 0.3 ? 0 : v < 0.55 ? 1 : v < 0.8 ? 2 : v < 0.93 ? 3 : 4
  })
  const color = ['#201C2B', 'rgba(168,85,247,0.3)', 'rgba(168,85,247,0.55)', 'rgba(168,85,247,0.8)', '#C084FC']
  const bars = [40, 65, 30, 85, 55, 100, 20]
  return (
    <div className="flex w-full max-w-[560px] items-end justify-center gap-6">
      <div className="grid w-full max-w-[400px] flex-1 grid-flow-col grid-rows-7 gap-[5px]" aria-hidden="true">
        {cells.map((l, i) => (
          <span key={i} className="aspect-square rounded-[4px]" style={{ background: color[l] }} />
        ))}
      </div>
      <div className="hidden h-32 items-end gap-2 sm:flex" aria-hidden="true">
        {bars.map((h, i) => (
          <span
            key={i}
            className="w-4 rounded-md"
            style={{
              height: `${h}%`,
              background: i === 5 ? 'linear-gradient(#C084FC,#A855F7)' : 'rgba(168,85,247,0.4)',
              boxShadow: i === 5 ? '0 0 16px rgba(168,85,247,0.5)' : undefined,
            }}
          />
        ))}
      </div>
    </div>
  )
}

const badges = [
  { label: '1º passo', color: '#34D399', icon: '⚑' },
  { label: 'Embalado', color: '#F59E0B', icon: '🔥' },
  { label: 'Imparável', color: '#FB7185', icon: '⚡' },
  { label: '10 horas', color: '#60A5FA', icon: '⏱' },
  { label: 'Centenário', color: '#FACC15', icon: '★', locked: true },
]

export default function FeaturesSection() {
  return (
    <section id="recursos" className="relative z-10 px-5 py-24 lg:py-32">
      <div className="mx-auto max-w-page">
        <SectionHeader
          eyebrow="Recursos"
          title={
            <>
              Tudo que você precisa para <span className="text-gradient">estudar melhor</span>
            </>
          }
          subtitle="Pensado do primeiro toque até a última revisão: cronometrar, organizar e enxergar sua evolução."
        />

        <div className="grid gap-5 lg:grid-cols-3">
          <Card
            className="lg:col-span-2"
            title="Timer Pomodoro inteligente"
            body="Presets de 15 min a 1h30 ou duração personalizada. Modo Pomodoro com pausas automáticas, +5 min quando você está embalado e aviso de fim de sessão mesmo com o app fechado."
            tone="rgba(168,85,247,0.6)"
          >
            <div className="flex w-full flex-col items-center gap-6 sm:flex-row sm:justify-center sm:gap-10">
              <Dial size={170} progress={0.68} label="EM FOCO" time="17:12" />
              <div className="flex flex-col items-center gap-3 sm:items-start">
                <div className="flex rounded-full border border-line bg-surface-hi p-1 text-sm font-bold">
                  <span className="rounded-full bg-surface-higher px-4 py-1.5">Livre</span>
                  <span className="px-4 py-1.5 text-sub">Pomodoro</span>
                </div>
                <div className="flex gap-1.5">
                  {presets.map((p, i) => (
                    <span
                      key={p}
                      className={`rounded-xl border px-2.5 py-1.5 text-sm font-extrabold ${
                        i === 1 ? 'border-white bg-white text-bg' : 'border-line bg-surface-hi text-ink'
                      }`}
                    >
                      {p}
                    </span>
                  ))}
                </div>
              </div>
            </div>
          </Card>

          <Card
            delay={80}
            title="Modo foco de verdade"
            body="A tela escurece sozinha durante a sessão para poupar bateria e cortar a tentação. Deslize para cima quando precisar."
          >
            <div className="relative flex h-40 w-full flex-col items-center justify-center overflow-hidden rounded-2xl bg-black">
              <svg viewBox="0 0 300 40" className="w-full" aria-hidden="true">
                <path
                  d="M0 20 Q 15 17 30 21 T 60 19 T 90 22 T 120 18 T 150 20 T 180 23 T 210 18 T 240 21 T 270 19 T 300 20"
                  stroke="rgba(255,255,255,0.25)"
                  strokeWidth="1.2"
                  fill="none"
                />
              </svg>
              <svg viewBox="0 0 24 24" className="absolute bottom-3 h-7 w-7 animate-bounce text-white/80" fill="none" aria-hidden="true">
                <path d="M6 15l6-6 6 6" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" />
              </svg>
            </div>
          </Card>

          <Card
            delay={60}
            title="Tarefas com 1 toque"
            body="Organize por matéria com meta de minutos. Toque no ▶ e o timer já abre configurado — no fim, marque como concluída."
            tone="rgba(52,211,153,0.35)"
          >
            <TasksMini />
          </Card>

          <Card
            delay={120}
            className="lg:col-span-2"
            title="Estatísticas que motivam"
            body="Total estudado, média por sessão, semana em barras, tempo por matéria e um mapa de consistência das últimas 12 semanas. Compartilhe seu progresso com um toque."
            tone="rgba(96,165,250,0.45)"
          >
            <Heatmap />
          </Card>

          <Card
            delay={60}
            title="Metas e lembretes"
            body="Defina uma meta diária e receba um lembrete no horário em que você costuma estudar."
            tone="rgba(245,158,11,0.35)"
          >
            <div className="flex items-center gap-5">
              <div className="relative h-24 w-24">
                <svg viewBox="0 0 36 36" className="h-full w-full -rotate-90" aria-hidden="true">
                  <circle cx="18" cy="18" r="15" fill="none" stroke="#201C2B" strokeWidth="3.5" />
                  <circle cx="18" cy="18" r="15" fill="none" stroke="#34D399" strokeWidth="3.5" strokeLinecap="round" strokeDasharray="94.2" strokeDashoffset="23.5" />
                </svg>
                <span className="absolute inset-0 grid place-items-center text-lg font-extrabold">75%</span>
              </div>
              <div className="space-y-2">
                <p className="rounded-xl bg-surface-hi px-3 py-2 text-sm font-bold">🎯 Meta: 2h por dia</p>
                <p className="rounded-xl bg-surface-hi px-3 py-2 text-sm font-bold">🔔 Lembrete às 20:00</p>
              </div>
            </div>
          </Card>

          <Card
            delay={120}
            className="lg:col-span-2"
            title="Níveis e conquistas"
            body="Cada hora de foco te leva de Iniciante a Lenda. Desbloqueie conquistas por sequência de dias, horas e sessões — e mantenha o fogo 🔥 aceso."
            tone="rgba(251,113,133,0.35)"
          >
            <div className="flex w-full flex-col items-center gap-5">
              <div className="w-full max-w-md">
                <div className="mb-2 flex justify-between text-sm font-bold">
                  <span className="rounded-lg bg-gradient-to-r from-violet to-sky px-2.5 py-1 text-white">Nível 7 · Disciplinado</span>
                  <span className="text-sub">75h de foco</span>
                </div>
                <div className="h-2 overflow-hidden rounded-full bg-surface-higher">
                  <div className="h-full w-[82%] rounded-full bg-gradient-to-r from-violet to-sky" />
                </div>
              </div>
              <ul className="flex flex-wrap justify-center gap-3">
                {badges.map(b => (
                  <li key={b.label} className="flex flex-col items-center gap-1.5">
                    <span
                      className="grid h-14 w-14 place-items-center rounded-full border-[3px] text-xl"
                      style={{
                        borderColor: b.locked ? '#26222F' : b.color,
                        background: b.locked ? '#0F0D16' : `${b.color}18`,
                        color: b.color,
                        filter: b.locked ? 'grayscale(1) opacity(0.5)' : undefined,
                      }}
                      aria-hidden="true"
                    >
                      {b.locked ? '🔒' : b.icon}
                    </span>
                    <span className="text-xs font-bold text-sub">{b.label}</span>
                  </li>
                ))}
              </ul>
            </div>
          </Card>
        </div>
      </div>
    </section>
  )
}
