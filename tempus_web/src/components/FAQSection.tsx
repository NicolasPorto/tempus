import { useState } from 'react'
import RevealWrapper from './RevealWrapper'

const faqs = [
  {
    q: 'O Tempus é gratuito?',
    a: 'Sim, totalmente gratuito. Sem assinaturas, sem anúncios intrusivos e sem limitações de uso. O app completo está disponível para todos.',
  },
  {
    q: 'Funciona sem internet?',
    a: 'Sim. O Tempus funciona completamente offline. Todas as suas sessões, tarefas e estatísticas são salvas localmente no dispositivo.',
  },
  {
    q: 'Posso personalizar o tempo das sessões?',
    a: 'Sim. Temos presets rápidos de 15, 20, 25 e 30 minutos. Você também pode definir qualquer duração personalizada que preferir.',
  },
  {
    q: 'Está disponível para iOS e Android?',
    a: 'Sim, o Tempus está disponível nas duas plataformas. Baixe gratuitamente na App Store ou no Google Play.',
  },
  {
    q: 'Meus dados ficam salvos?',
    a: 'Seu histórico de sessões, sequência diária (streak), tarefas e estatísticas ficam salvos localmente no seu dispositivo.',
  },
]

function ChevronIcon({ open }: { open: boolean }) {
  return (
    <svg
      width="18"
      height="18"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      style={{
        transition: 'transform 0.2s ease',
        transform: open ? 'rotate(180deg)' : 'rotate(0deg)',
        flexShrink: 0,
      }}
    >
      <polyline points="6 9 12 15 18 9" />
    </svg>
  )
}

export default function FAQSection() {
  const [open, setOpen] = useState<number | null>(null)

  return (
    <section
      id="faq"
      style={{
        position: 'relative',
        zIndex: 1,
        padding: '80px 16px',
        maxWidth: 720,
        margin: '0 auto',
      }}
    >
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
          ✦ Dúvidas frequentes
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
          Perguntas <span className="gradient-text">frequentes</span>
        </h2>
        <p style={{ fontSize: 16, color: '#606060', margin: 0 }}>
          Tudo que você precisa saber antes de baixar
        </p>
      </RevealWrapper>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
        {faqs.map((faq, i) => (
          <RevealWrapper key={faq.q} delay={i * 80}>
            <div
              style={{
                background: open === i ? 'rgba(172, 70, 255, 0.05)' : 'rgba(18, 14, 28, 0.6)',
                border: `1px solid ${open === i ? 'rgba(172, 70, 255, 0.2)' : 'rgba(255,255,255,0.07)'}`,
                borderRadius: 14,
                overflow: 'hidden',
                transition: 'background 0.2s ease, border-color 0.2s ease',
              }}
            >
              {/* Question */}
              <button
                onClick={() => setOpen(open === i ? null : i)}
                style={{
                  width: '100%',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  gap: 16,
                  padding: '20px 22px',
                  background: 'none',
                  border: 'none',
                  cursor: 'pointer',
                  textAlign: 'left',
                }}
              >
                <span
                  style={{
                    fontSize: 15,
                    fontWeight: 600,
                    color: open === i ? '#F0F0F0' : '#C8C8C8',
                    transition: 'color 0.2s ease',
                  }}
                >
                  {faq.q}
                </span>
                <span style={{ color: open === i ? '#AC46FF' : '#484848', transition: 'color 0.2s ease' }}>
                  <ChevronIcon open={open === i} />
                </span>
              </button>

              {/* Answer */}
              <div
                style={{
                  maxHeight: open === i ? 200 : 0,
                  overflow: 'hidden',
                  transition: 'max-height 0.28s ease',
                }}
              >
                <p
                  style={{
                    fontSize: 14,
                    color: '#808080',
                    lineHeight: 1.75,
                    margin: 0,
                    padding: '0 22px 20px',
                  }}
                >
                  {faq.a}
                </p>
              </div>
            </div>
          </RevealWrapper>
        ))}
      </div>
    </section>
  )
}
