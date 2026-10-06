import { Reveal, SectionHeader } from './ui'

const steps = [
  {
    n: '01',
    title: 'Escolha',
    body: 'Selecione a matéria — ou uma tarefa — e o tempo: 15, 25, 45 min, 1h, 1h30, personalizado ou Pomodoro.',
    icon: (
      <path d="M4 6h16M4 12h10M4 18h7" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" />
    ),
  },
  {
    n: '02',
    title: 'Foque',
    body: 'Dê o play. A tela escurece, os alertas a cada 5 min te mantêm no ritmo e você é avisado quando terminar.',
    icon: (
      <>
        <circle cx="12" cy="13" r="7.5" stroke="currentColor" strokeWidth="2.2" />
        <path d="M12 9.5V13l2.5 2M9.5 3h5" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" />
      </>
    ),
  },
  {
    n: '03',
    title: 'Evolua',
    body: 'Acompanhe horas, sequência e consistência. Suba de nível, bata a meta do dia e desbloqueie conquistas.',
    icon: (
      <path d="M4 17l5-5 4 4 7-8M15 8h5v5" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round" />
    ),
  },
]

export default function HowItWorksSection() {
  return (
    <section id="como-funciona" className="relative z-10 px-5 py-24 lg:py-32">
      <div className="mx-auto max-w-page">
        <SectionHeader
          eyebrow="Como funciona"
          title={
            <>
              Três passos. <span className="text-gradient">Zero enrolação.</span>
            </>
          }
        />
        <ol className="relative grid gap-5 md:grid-cols-3">
          {/* connector */}
          <div
            className="pointer-events-none absolute left-[16%] right-[16%] top-[52px] hidden h-px md:block"
            style={{ background: 'linear-gradient(90deg, transparent, rgba(168,85,247,0.5), rgba(96,165,250,0.5), transparent)' }}
          />
          {steps.map((s, i) => (
            <Reveal as="li" key={s.n} delay={i * 120} className="relative">
              <div className="card h-full p-7 text-center">
                <div className="relative mx-auto mb-6 grid h-[72px] w-[72px] place-items-center rounded-2xl bg-gradient-to-br from-violet to-sky text-white shadow-[0_16px_40px_-10px_rgba(168,85,247,0.7)]">
                  <svg viewBox="0 0 24 24" className="h-8 w-8" fill="none" aria-hidden="true">
                    {s.icon}
                  </svg>
                  <span className="absolute -right-2 -top-2 rounded-lg border border-line bg-bg px-1.5 py-0.5 text-[11px] font-extrabold tabular-nums text-sub">
                    {s.n}
                  </span>
                </div>
                <h3 className="text-2xl font-extrabold tracking-tight">{s.title}</h3>
                <p className="mx-auto mt-3 max-w-xs leading-relaxed text-sub">{s.body}</p>
              </div>
            </Reveal>
          ))}
        </ol>
      </div>
    </section>
  )
}
