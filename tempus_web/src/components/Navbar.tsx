import { useEffect, useState } from 'react'
import { Logo, PlayStoreButton } from './ui'

const links = [
  { label: 'Recursos', href: '#recursos' },
  { label: 'O app', href: '#app' },
  { label: 'Como funciona', href: '#como-funciona' },
  { label: 'Dúvidas', href: '#faq' },
]

export default function Navbar() {
  const [scrolled, setScrolled] = useState(false)
  const [open, setOpen] = useState(false)

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 24)
    onScroll()
    window.addEventListener('scroll', onScroll, { passive: true })
    return () => window.removeEventListener('scroll', onScroll)
  }, [])

  return (
    <header className="fixed inset-x-0 top-0 z-50 px-4 pt-3 sm:px-6">
      <nav
        className={`mx-auto flex h-16 max-w-page items-center justify-between rounded-2xl border px-4 transition-all duration-300 sm:px-5 ${
          scrolled || open
            ? 'border-white/[0.08] bg-[#0f0d16]/75 shadow-[0_20px_50px_-20px_rgba(0,0,0,0.8)] backdrop-blur-xl'
            : 'border-transparent bg-transparent'
        }`}
        aria-label="Principal"
      >
        <a href="#inicio" className="flex items-center gap-2.5" onClick={() => setOpen(false)}>
          <Logo size={30} />
          <span className="text-xl font-extrabold tracking-tight">Tempus</span>
        </a>

        <ul className="hidden items-center gap-1 md:flex">
          {links.map(l => (
            <li key={l.href}>
              <a
                href={l.href}
                className="rounded-xl px-3.5 py-2 text-sm font-semibold text-sub transition-colors hover:bg-white/[0.05] hover:text-ink"
              >
                {l.label}
              </a>
            </li>
          ))}
        </ul>

        <div className="flex items-center gap-2">
          <PlayStoreButton size="md" label="Baixar grátis" className="hidden sm:inline-flex" />
          <button
            type="button"
            className="grid h-11 w-11 place-items-center rounded-xl text-ink md:hidden"
            aria-label={open ? 'Fechar menu' : 'Abrir menu'}
            aria-expanded={open}
            onClick={() => setOpen(o => !o)}
          >
            <span className="relative block h-3.5 w-5">
              {[0, 1, 2].map(i => (
                <span
                  key={i}
                  className="absolute left-0 h-0.5 w-5 rounded bg-current transition-all duration-200"
                  style={{
                    top: open ? 6 : i * 6,
                    opacity: open && i === 1 ? 0 : 1,
                    transform: open ? `rotate(${i === 0 ? 45 : i === 2 ? -45 : 0}deg)` : 'none',
                  }}
                />
              ))}
            </span>
          </button>
        </div>
      </nav>

      {/* Mobile menu */}
      <div
        className={`mx-auto mt-2 max-w-page overflow-hidden rounded-2xl border border-white/[0.08] bg-[#0f0d16]/90 backdrop-blur-xl transition-all duration-300 md:hidden ${
          open ? 'max-h-96 opacity-100' : 'pointer-events-none max-h-0 opacity-0'
        }`}
      >
        <ul className="p-2">
          {links.map(l => (
            <li key={l.href}>
              <a
                href={l.href}
                onClick={() => setOpen(false)}
                className="block rounded-xl px-4 py-3.5 text-base font-semibold text-ink/90 hover:bg-white/[0.05]"
              >
                {l.label}
              </a>
            </li>
          ))}
        </ul>
        <div className="p-3 pt-0">
          <PlayStoreButton className="w-full" />
        </div>
      </div>
    </header>
  )
}
