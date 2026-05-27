import { useState, useEffect } from 'react'

const sections = [
  { id: 'inicio', label: 'Início' },
  { id: 'funcionalidades', label: 'Funcionalidades' },
  { id: 'como-funciona', label: 'Como funciona' },
  { id: 'depoimentos', label: 'Depoimentos' },
  { id: 'faq', label: 'FAQ' },
]

export default function SideNav() {
  const [active, setActive] = useState('inicio')

  useEffect(() => {
    const onScroll = () => {
      const mid = window.scrollY + window.innerHeight * 0.4
      let current = sections[0].id
      for (const { id } of sections) {
        const el = document.getElementById(id)
        if (el && el.offsetTop <= mid) current = id
      }
      setActive(current)
    }
    window.addEventListener('scroll', onScroll, { passive: true })
    onScroll()
    return () => window.removeEventListener('scroll', onScroll)
  }, [])

  const scrollTo = (id: string) => {
    const el = document.getElementById(id)
    if (el) window.scrollTo({ top: el.offsetTop - 80, behavior: 'smooth' })
  }

  return (
    <div
      className="side-nav"
      style={{
        position: 'fixed',
        left: 32,
        top: '50%',
        transform: 'translateY(-50%)',
        zIndex: 150,
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'flex-start',
      }}
    >
      {sections.map((section, i) => (
        <div key={section.id} style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-start' }}>
          <button
            onClick={() => scrollTo(section.id)}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: 12,
              background: 'none',
              border: 'none',
              cursor: 'pointer',
              padding: '2px 0',
            }}
          >
            {/* Dot */}
            <div
              style={{
                width: active === section.id ? 9 : 6,
                height: active === section.id ? 9 : 6,
                borderRadius: '50%',
                background: active === section.id
                  ? 'linear-gradient(135deg, #AC46FF, #2B7FFF)'
                  : 'rgba(255,255,255,0.28)',
                boxShadow: active === section.id
                  ? '0 0 8px rgba(172, 70, 255, 0.55)'
                  : 'none',
                flexShrink: 0,
                transition: 'all 0.2s ease',
              }}
            />
            {/* Label */}
            <span
              style={{
                fontSize: 11,
                color: active === section.id ? '#E0E0E0' : '#606060',
                fontWeight: active === section.id ? 600 : 400,
                letterSpacing: 0.3,
                whiteSpace: 'nowrap',
                transition: 'color 0.2s ease',
                userSelect: 'none',
              }}
            >
              {section.label}
            </span>
          </button>

          {/* Connector line */}
          {i < sections.length - 1 && (
            <div
              style={{
                width: 1,
                height: 40,
                background: 'linear-gradient(to bottom, rgba(255,255,255,0.07), rgba(255,255,255,0.03))',
                marginLeft: 4,
                marginTop: 7,
                marginBottom: 7,
              }}
            />
          )}
        </div>
      ))}
    </div>
  )
}
