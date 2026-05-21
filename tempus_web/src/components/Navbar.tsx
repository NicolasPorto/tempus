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
    document.getElementById(id)?.scrollIntoView({ behavior: 'smooth' })
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
          transition: 'background 0.3s ease, border-color 0.3s ease',
          background: scrolled ? 'rgba(6, 4, 10, 0.85)' : 'transparent',
          backdropFilter: scrolled ? 'blur(16px)' : 'none',
          WebkitBackdropFilter: scrolled ? 'blur(16px)' : 'none',
          borderBottom: `1px solid ${scrolled ? 'rgba(255,255,255,0.08)' : 'transparent'}`,
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
          <div
            style={{
              width: 36,
              height: 36,
              borderRadius: 10,
              background: 'linear-gradient(135deg, rgba(172,70,255,0.25), rgba(43,127,255,0.25))',
              border: '1.5px solid rgba(255,255,255,0.15)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontSize: 18,
            }}
          >
            ⏱
          </div>
          <span
            className="gradient-text"
            style={{ fontSize: 20, fontWeight: 700, letterSpacing: '-0.5px' }}
          >
            Tempus
          </span>
        </button>

        {/* Desktop links */}
        <div className="nav-desktop" style={{ display: 'flex', gap: 32, alignItems: 'center' }}>
          {[
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
                fontSize: 14,
                fontWeight: 500,
                color: '#A0A0A0',
                padding: 0,
                transition: 'color 0.2s',
              }}
              onMouseEnter={e => (e.currentTarget.style.color = '#F4F4F4')}
              onMouseLeave={e => (e.currentTarget.style.color = '#A0A0A0')}
            >
              {label}
            </button>
          ))}
          <button
            className="btn-gradient"
            onClick={() => scrollTo('como-funciona')}
            style={{ padding: '8px 22px', fontSize: 14 }}
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
                transition: 'opacity 0.2s, transform 0.2s',
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
          background: 'rgba(6, 4, 10, 0.97)',
          backdropFilter: 'blur(16px)',
          WebkitBackdropFilter: 'blur(16px)',
          borderBottom: '1px solid rgba(255,255,255,0.08)',
          padding: menuOpen ? '16px 24px 24px' : '0 24px',
          display: 'flex',
          flexDirection: 'column',
          gap: 4,
          overflow: 'hidden',
          maxHeight: menuOpen ? 300 : 0,
          transition: 'max-height 0.3s ease, padding 0.3s ease',
        }}
        className="nav-mobile-menu"
      >
        {[
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
