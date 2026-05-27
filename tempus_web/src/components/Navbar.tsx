import { useState, useEffect } from 'react'

export default function Navbar() {
  const [scrolled, setScrolled] = useState(false)
  const [menuOpen, setMenuOpen] = useState(false)

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 30)
    window.addEventListener('scroll', onScroll, { passive: true })
    return () => window.removeEventListener('scroll', onScroll)
  }, [])

  const scrollTo = (id: string) => {
    const el = document.getElementById(id)
    if (el) window.scrollTo({ top: el.offsetTop - 80, behavior: 'smooth' })
    setMenuOpen(false)
  }

  return (
    <>
      <nav
        style={{
          position: 'fixed',
          top: 0,
          left: 0,
          right: 0,
          zIndex: 200,
          height: 64,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          padding: '0 clamp(16px, 4vw, 48px)',
          transition: 'background 0.4s ease, backdrop-filter 0.4s ease, border-color 0.4s ease',
          background: scrolled
            ? 'rgba(6, 4, 10, 0.38)'
            : 'transparent',
          backdropFilter: scrolled ? 'blur(28px) saturate(160%) brightness(1.08)' : 'none',
          WebkitBackdropFilter: scrolled ? 'blur(28px) saturate(160%) brightness(1.08)' : 'none',
          borderBottom: `1px solid ${scrolled ? 'rgba(255,255,255,0.09)' : 'transparent'}`,
        }}
      >
        {/* Logo */}
        <button
          onClick={() => scrollTo('inicio')}
          style={{
            background: 'none',
            border: 'none',
            cursor: 'pointer',
            display: 'flex',
            alignItems: 'center',
            gap: 10,
            padding: 0,
          }}
        >
          <img
            src="/icon_login.svg"
            alt="Tempus"
            width={30}
            height={30}
            className="logo-glow"
            style={{ display: 'block' }}
          />
          <span
            className="gradient-text"
            style={{ fontSize: 20, fontWeight: 700, letterSpacing: '-0.5px' }}
          >
            Tempus
          </span>
        </button>

        {/* Desktop: only download button */}
        <div className="nav-desktop" style={{ display: 'flex', alignItems: 'center' }}>
          <button
            className="btn-gradient"
            onClick={() => scrollTo('como-funciona')}
            style={{ padding: '9px 22px', fontSize: 13, letterSpacing: 0.2 }}
          >
            Baixar
          </button>
        </div>

        {/* Hamburger (mobile) */}
        <button
          className="nav-hamburger"
          onClick={() => setMenuOpen(o => !o)}
          aria-label="Menu"
          style={{
            background: 'none',
            border: 'none',
            cursor: 'pointer',
            display: 'flex',
            flexDirection: 'column',
            gap: 5,
            padding: 4,
          }}
        >
          {[0, 1, 2].map(i => (
            <span
              key={i}
              style={{
                display: 'block',
                width: 22,
                height: 2,
                borderRadius: 2,
                background: '#F4F4F4',
                transition: 'opacity 0.15s, transform 0.15s',
                opacity: menuOpen && i === 1 ? 0 : 1,
                transform:
                  menuOpen && i === 0 ? 'rotate(45deg) translate(5px, 5px)'
                  : menuOpen && i === 2 ? 'rotate(-45deg) translate(5px, -5px)'
                  : 'none',
              }}
            />
          ))}
        </button>
      </nav>

      {/* Mobile dropdown */}
      <div
        style={{
          position: 'fixed',
          top: 64,
          left: 0,
          right: 0,
          zIndex: 199,
          background: 'rgba(6, 4, 10, 0.88)',
          backdropFilter: 'blur(28px) saturate(160%)',
          WebkitBackdropFilter: 'blur(28px) saturate(160%)',
          borderBottom: '1px solid rgba(255,255,255,0.07)',
          padding: menuOpen ? '16px 24px 24px' : '0 24px',
          display: 'flex',
          flexDirection: 'column',
          gap: 4,
          overflow: 'hidden',
          maxHeight: menuOpen ? 300 : 0,
          transition: 'max-height 0.25s ease, padding 0.25s ease',
        }}
        className="nav-mobile-menu"
      >
        {[
          { label: 'Início', id: 'inicio' },
          { label: 'Funcionalidades', id: 'funcionalidades' },
          { label: 'Como funciona', id: 'como-funciona' },
        ].map(({ label, id }) => (
          <button
            key={id}
            onClick={() => scrollTo(id)}
            style={{
              background: 'none',
              border: 'none',
              cursor: 'pointer',
              fontSize: 16,
              fontWeight: 500,
              color: '#D4D4D4',
              padding: '12px 0',
              textAlign: 'left',
              borderBottom: '1px solid rgba(255,255,255,0.06)',
            }}
          >
            {label}
          </button>
        ))}
        <button
          className="btn-gradient"
          style={{ marginTop: 12, padding: '13px 0', fontSize: 15, width: '100%' }}
          onClick={() => scrollTo('como-funciona')}
        >
          Baixar o Tempus
        </button>
      </div>
    </>
  )
}
