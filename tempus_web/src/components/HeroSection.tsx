import type { ReactNode } from 'react'
import { Dial, Phone, PlayStoreButton, Reveal } from './ui'

function Check() {
  return (
    <svg viewBox="0 0 20 20" className="h-4 w-4 text-mint" fill="none" aria-hidden="true">
      <path d="M4 10.5l3.5 3.5L16 6" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  )
}

function FloatingCard({
  className,
  children,
  rotate = 0,
}: {
  className: string
  children: ReactNode
  rotate?: number
}) {
  return (
    <div
      className={`float absolute rounded-2xl border border-violet/25 bg-[#17141f]/95 p-3.5 shadow-[0_24px_50px_-12px_rgba(0,0,0,0.75)] backdrop-blur ${className}`}
      style={{ ['--r' as string]: `${rotate}deg` }}
    >
      {children}
    </div>
  )
}

export default function HeroSection() {
  return (
    <section id="inicio" className="relative z-10 overflow-x-clip px-5 pb-16 pt-32 sm:pt-36 lg:pb-24">
      <div className="mx-auto grid max-w-page items-center gap-16 lg:grid-cols-[1.1fr_0.9fr] lg:gap-10">
        <div className="text-center lg:text-left">
          <Reveal immediate>
            <a
              href="#video"
              className="mb-7 inline-flex items-center gap-2 rounded-full border border-violet/30 bg-violet/10 py-1.5 pl-2 pr-4 text-sm font-semibold text-violet-soft transition-colors hover:bg-violet/15"
            >
              <span className="rounded-full bg-violet px-2 py-0.5 text-[11px] font-extrabold uppercase tracking-wider text-white">
                Novo
              </span>
              Visual novo, metas e conquistas →
            </a>
          </Reveal>
          <Reveal delay={80} immediate>
            <h1 className="text-[clamp(44px,8vw,84px)] font-extrabold leading-[0.98] tracking-[-0.045em]">
              Estude com foco.
              <br />
              <span className="text-gradient">De verdade.</span>
            </h1>
          </Reveal>
          <Reveal delay={160} immediate>
            <p className="mx-auto mt-7 max-w-xl text-lg leading-relaxed text-sub sm:text-xl lg:mx-0">
              Timer Pomodoro, tarefas por matéria e estatísticas que mostram sua evolução — num app
              que apaga a tela e deixa as distrações do lado de fora.
            </p>
          </Reveal>
          <Reveal delay={240} immediate>
            <div className="mt-10 flex flex-col items-center gap-3 sm:flex-row sm:justify-center lg:justify-start">
              <PlayStoreButton />
              <a href="#video" className="btn-ghost">
                <svg viewBox="0 0 24 24" className="h-5 w-5" fill="currentColor" aria-hidden="true">
                  <path d="M8 5.5v13a1 1 0 0 0 1.5.86l10.8-6.5a1 1 0 0 0 0-1.72L9.5 4.64A1 1 0 0 0 8 5.5z" />
                </svg>
                Ver em 15 segundos
              </a>
            </div>
          </Reveal>
          <Reveal delay={320} immediate>
            <ul className="mt-9 flex flex-wrap justify-center gap-x-6 gap-y-2 text-sm font-semibold text-sub lg:justify-start">
              {['100% grátis', 'Entre com sua conta Google', 'Progresso salvo na nuvem'].map(t => (
                <li key={t} className="flex items-center gap-2">
                  <Check />
                  {t}
                </li>
              ))}
            </ul>
          </Reveal>
        </div>

        <Reveal delay={200} className="relative mx-auto w-full max-w-[420px]" immediate>
          {/* Dial behind the phone */}
          <div className="pointer-events-none absolute left-1/2 top-1/2 -z-10 -translate-x-1/2 -translate-y-1/2 opacity-60">
            <Dial size={560} progress={0.78} head={false} />
          </div>
          <Phone
            src="/screens/modo-foco.webp"
            alt="Tela do modo foco do Tempus: timer de 44:57 em Cálculo II"
            className="mx-auto w-[min(78vw,300px)]"
            priority
          />
          <FloatingCard className="-left-2 top-[14%] sm:-left-10" rotate={-4}>
            <div className="flex items-center gap-3">
              <span className="grid h-10 w-10 place-items-center rounded-xl bg-amber/15 text-xl">🔥</span>
              <div>
                <p className="text-lg font-extrabold leading-none text-amber">12 dias</p>
                <p className="mt-1 text-xs font-semibold text-sub">seguidos de estudo</p>
              </div>
            </div>
          </FloatingCard>
          <FloatingCard className="-right-2 top-[46%] w-48 sm:-right-12" rotate={3}>
            <p className="eyebrow !text-[10px]">Meta de hoje</p>
            <p className="mt-1.5 text-base font-extrabold">1h 30 de 2h</p>
            <div className="mt-2.5 h-1.5 overflow-hidden rounded-full bg-surface-higher">
              <div className="h-full w-3/4 rounded-full bg-gradient-to-r from-violet to-sky" />
            </div>
          </FloatingCard>
          <FloatingCard className="bottom-[8%] -left-1 sm:-left-8" rotate={-2}>
            <div className="flex items-center gap-2.5">
              <span className="grid h-9 w-9 place-items-center rounded-full border-2 border-mint text-mint">
                <svg viewBox="0 0 20 20" className="h-4 w-4" fill="currentColor" aria-hidden="true">
                  <path d="M5 2h1.5v16H5zM6.5 3h9l-2.5 3.5 2.5 3.5h-9z" />
                </svg>
              </span>
              <div>
                <p className="text-sm font-extrabold leading-none">Conquista!</p>
                <p className="mt-1 text-xs font-semibold text-sub">1º passo desbloqueado</p>
              </div>
            </div>
          </FloatingCard>
        </Reveal>
      </div>
    </section>
  )
}
