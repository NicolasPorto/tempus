import { useEffect, useState } from 'react'
import { PLAY_STORE_URL } from '../config'
import { Dial, Logo, PlayStoreButton, Reveal } from './ui'

function FinalCTA() {
  return (
    <section className="relative z-10 px-5 pb-24 pt-8">
      <Reveal className="mx-auto max-w-page">
        <div className="relative overflow-hidden rounded-[2.5rem] border border-violet/25 px-6 py-16 text-center sm:px-12 sm:py-20"
          style={{ background: 'radial-gradient(ellipse at 50% 0%, rgba(168,85,247,0.35), transparent 60%), linear-gradient(160deg,#1a1428,#0d0b16)' }}
        >
          <div className="pointer-events-none absolute -bottom-40 -right-32 opacity-40 sm:-right-16" aria-hidden="true">
            <Dial size={420} progress={0.82} animate={false} head={false} />
          </div>
          <div className="pointer-events-none absolute -left-40 -top-40 opacity-25" aria-hidden="true">
            <Dial size={360} progress={0.4} animate={false} head={false} />
          </div>
          <div className="relative">
            <Logo size={64} />
          </div>
          <h2 className="relative mx-auto mt-7 max-w-2xl text-[clamp(34px,6vw,64px)] font-extrabold leading-[1.02] tracking-[-0.04em]">
            Sua próxima sessão de foco começa <span className="text-gradient">agora.</span>
          </h2>
          <p className="relative mx-auto mt-6 max-w-md text-lg text-sub">
            Grátis no Google Play. Entre com sua conta Google e dê o play em menos de um minuto.
          </p>
          <div className="relative mt-10 flex justify-center">
            <PlayStoreButton label="Baixar o Tempus" />
          </div>
        </div>
      </Reveal>
    </section>
  )
}

export default function Footer() {
  return (
    <>
      <FinalCTA />
      <footer className="relative z-10 border-t border-white/[0.06] px-5 pb-28 pt-14 sm:pb-10">
        <div className="mx-auto flex max-w-page flex-col gap-10 md:flex-row md:items-start md:justify-between">
          <div className="max-w-xs">
            <a href="#inicio" className="flex items-center gap-2.5">
              <Logo size={30} />
              <span className="text-xl font-extrabold tracking-tight">Tempus</span>
            </a>
            <p className="mt-4 leading-relaxed text-sub">
              Timer Pomodoro, tarefas e estatísticas para quem quer estudar com foco.
            </p>
          </div>

          <nav aria-label="Rodapé" className="grid grid-cols-2 gap-x-14 gap-y-3 text-sm font-semibold">
            <p className="eyebrow col-span-2 mb-1">Navegação</p>
            {[
              ['Recursos', '#recursos'],
              ['O app', '#app'],
              ['Como funciona', '#como-funciona'],
              ['Dúvidas', '#faq'],
            ].map(([l, h]) => (
              <a key={h} href={h} className="text-sub transition-colors hover:text-ink">
                {l}
              </a>
            ))}
          </nav>

          <div>
            <p className="eyebrow mb-4">Baixe</p>
            <a
              href={PLAY_STORE_URL}
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center gap-3 rounded-2xl border border-line bg-surface-hi/70 px-4 py-3 transition-colors hover:border-violet/40"
            >
              <svg viewBox="0 0 24 24" className="h-6 w-6 text-mint" fill="currentColor" aria-hidden="true">
                <path d="M17.6 9.48l1.84-3.18a.38.38 0 0 0-.66-.38l-1.86 3.22A11.4 11.4 0 0 0 12 8.2c-1.77 0-3.43.37-4.92 1L5.22 5.92a.38.38 0 0 0-.66.38L6.4 9.48A10.8 10.8 0 0 0 1 18h22a10.8 10.8 0 0 0-5.4-8.52zM7 15.25a1.25 1.25 0 1 1 0-2.5 1.25 1.25 0 0 1 0 2.5zm10 0a1.25 1.25 0 1 1 0-2.5 1.25 1.25 0 0 1 0 2.5z" />
              </svg>
              <span className="leading-tight">
                <span className="block text-[11px] font-semibold uppercase tracking-wider text-sub">Disponível no</span>
                <span className="block font-extrabold">Google Play</span>
              </span>
            </a>
          </div>
        </div>

        <div className="mx-auto mt-12 flex max-w-page flex-col items-center justify-between gap-3 border-t border-white/[0.05] pt-6 text-sm text-muted sm:flex-row">
          <p>© {new Date().getFullYear()} Tempus. Todos os direitos reservados.</p>
          <p>Feito com 💜 para estudantes brasileiros</p>
        </div>
      </footer>
      {/* Mobile sticky download bar */}
      <MobileStickyCTA />
    </>
  )
}

function MobileStickyCTA() {
  // Appears once the hero (which has its own CTA) is scrolled away.
  const [show, setShow] = useState(false)
  useEffect(() => {
    const onScroll = () => setShow(window.scrollY > window.innerHeight * 0.9)
    onScroll()
    window.addEventListener('scroll', onScroll, { passive: true })
    return () => window.removeEventListener('scroll', onScroll)
  }, [])
  return (
    <div
      className={`pointer-events-none fixed inset-x-0 bottom-0 z-40 p-3 transition-all duration-300 sm:hidden ${
        show ? 'translate-y-0 opacity-100' : 'translate-y-full opacity-0'
      }`}
      style={{ paddingBottom: 'max(12px, env(safe-area-inset-bottom))' }}
      aria-hidden={!show}
    >
      <a
        href={PLAY_STORE_URL}
        target="_blank"
        rel="noopener noreferrer"
        className={`btn-primary w-full py-4 text-base ${show ? 'pointer-events-auto' : ''}`}
        tabIndex={show ? 0 : -1}
        aria-label="Baixar o Tempus grátis no Google Play (abre em nova aba)"
      >
        Baixar grátis no Google Play
      </a>
    </div>
  )
}
