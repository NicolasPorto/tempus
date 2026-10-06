import { useEffect, useRef, useState } from 'react'
import { Phone, Reveal, SectionHeader } from './ui'

const screens = [
  {
    key: 'foco',
    tab: 'Foco',
    title: 'Escolha a matéria e dê o play',
    body: 'Saudação do dia, sua sequência 🔥, presets de tempo e a meta diária num só lugar.',
    src: '/screens/foco.webp',
    alt: 'Tela inicial do Tempus com timer de 25 minutos e a matéria Cálculo II selecionada',
  },
  {
    key: 'modo-foco',
    tab: 'Modo foco',
    title: 'Só você e o tempo',
    body: 'Anel na cor da matéria, horário de término e +5 min quando quiser estender. A tela apaga sozinha.',
    src: '/screens/modo-foco.webp',
    alt: 'Modo foco do Tempus com contagem regressiva e botões de encerrar e adicionar 5 minutos',
  },
  {
    key: 'tarefas',
    tab: 'Tarefas',
    title: 'Plano de estudos organizado',
    body: 'Filtre por matéria, arraste para reordenar, deslize para concluir. O ▶ abre o timer na tarefa.',
    src: '/screens/tarefas.webp',
    alt: 'Lista de tarefas do Tempus organizada por matéria com barra de progresso',
  },
  {
    key: 'estatisticas',
    tab: 'Estatísticas',
    title: 'Sua evolução, sem achismo',
    body: 'Tempo total, semana em barras e o mapa de consistência mostram se o hábito está pegando.',
    src: '/screens/estatisticas.webp',
    alt: 'Tela de estatísticas do Tempus com total estudado e atividade da semana',
  },
  {
    key: 'perfil',
    tab: 'Perfil',
    title: 'Níveis, conquistas e ajustes',
    body: 'Suba de nível a cada hora de foco, desbloqueie conquistas e ajuste som, meta e lembretes.',
    src: '/screens/perfil.webp',
    alt: 'Perfil do Tempus com nível, horas de foco e conquistas',
  },
]

export default function ShowcaseSection() {
  const [active, setActive] = useState(0)
  const [paused, setPaused] = useState(false)
  const sectionRef = useRef<HTMLElement>(null)
  const [inView, setInView] = useState(false)

  useEffect(() => {
    const el = sectionRef.current
    if (!el) return
    const io = new IntersectionObserver(([e]) => setInView(e.isIntersecting), { threshold: 0.3 })
    io.observe(el)
    return () => io.disconnect()
  }, [])

  useEffect(() => {
    const reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches
    if (paused || !inView || reduce) return
    const id = window.setTimeout(() => setActive(a => (a + 1) % screens.length), 4200)
    return () => window.clearTimeout(id)
  }, [active, paused, inView])

  return (
    <section
      id="app"
      ref={sectionRef}
      className="relative z-10 px-5 py-24 lg:py-32"
      onMouseEnter={() => setPaused(true)}
      onMouseLeave={() => setPaused(false)}
    >
      <div className="mx-auto max-w-page">
        <SectionHeader
          eyebrow="O app por dentro"
          title={
            <>
              Desenhado para <span className="text-gradient">não te distrair</span>
            </>
          }
          subtitle="Interface escura, limpa e direta. Cada tela tem um único trabalho."
        />

        <div className="grid items-center gap-12 lg:grid-cols-[1fr_auto_1fr]">
          {/* Tabs */}
          <Reveal className="min-w-0 lg:col-start-1">
            <div className="no-scrollbar -mx-5 flex gap-2 overflow-x-auto px-5 lg:mx-0 lg:flex-col lg:overflow-visible lg:px-0" role="tablist" aria-label="Telas do app">
              {screens.map((s, i) => {
                const on = i === active
                return (
                  <button
                    key={s.key}
                    role="tab"
                    aria-selected={on}
                    aria-controls="showcase-panel"
                    onClick={() => setActive(i)}
                    className={`group relative shrink-0 overflow-hidden rounded-2xl border text-left transition-all duration-300 lg:w-full lg:p-5 ${
                      on
                        ? 'border-violet/40 bg-violet/10 px-4 py-2.5'
                        : 'border-line bg-surface/60 px-4 py-2.5 hover:border-white/15'
                    }`}
                  >
                    <span className={`text-sm font-extrabold lg:text-base ${on ? 'text-ink' : 'text-sub'}`}>
                      <span className="mr-2 hidden tabular-nums text-muted lg:inline">0{i + 1}</span>
                      {s.tab}
                    </span>
                    <span
                      className={`hidden overflow-hidden text-sm leading-relaxed text-sub transition-all duration-300 lg:block ${
                        on ? 'mt-2 max-h-24 opacity-100' : 'max-h-0 opacity-0'
                      }`}
                    >
                      {s.body}
                    </span>
                    {on && !paused && inView && (
                      <span
                        key={active}
                        className="absolute bottom-0 left-0 h-0.5 bg-gradient-to-r from-violet to-sky"
                        style={{ animation: 'progress 4.2s linear forwards' }}
                      />
                    )}
                  </button>
                )
              })}
            </div>
          </Reveal>

          {/* Phone */}
          <Reveal delay={120} className="min-w-0 lg:col-start-2">
            <div id="showcase-panel" role="tabpanel" className="relative mx-auto w-[min(76vw,310px)]">
              <div className="relative">
                {/* stack the screens so the frame never jumps */}
                {screens.map((s, i) => (
                  <div
                    key={s.key}
                    className={`transition-all duration-500 ${i === 0 ? 'relative' : 'absolute inset-0'}`}
                    style={{
                      opacity: i === active ? 1 : 0,
                      transform: i === active ? 'none' : 'translateY(14px) scale(0.98)',
                      pointerEvents: i === active ? 'auto' : 'none',
                    }}
                    aria-hidden={i !== active}
                  >
                    <Phone src={s.src} alt={s.alt} />
                  </div>
                ))}
              </div>
            </div>
          </Reveal>

          {/* Caption */}
          <Reveal delay={200} className="min-w-0 text-center lg:col-start-3 lg:text-left">
            <p className="eyebrow mb-3 tabular-nums">
              {String(active + 1).padStart(2, '0')} / {String(screens.length).padStart(2, '0')}
            </p>
            <h3 key={active} className="text-3xl font-extrabold tracking-tight" style={{ animation: 'notif-in .45s ease both' }}>
              {screens[active].title}
            </h3>
            <p className="mx-auto mt-4 max-w-sm text-lg leading-relaxed text-sub lg:mx-0">{screens[active].body}</p>
          </Reveal>
        </div>
      </div>
    </section>
  )
}
