import { useId, useState } from 'react'
import { Reveal, SectionHeader } from './ui'

const faqs = [
  {
    q: 'O Tempus é gratuito?',
    a: 'Sim. Você baixa e usa todos os recursos sem pagar nada e sem assinatura. Para manter o app gratuito, às vezes aparece um anúncio quando você encerra os estudos do dia — nunca no meio de uma sessão de foco.',
  },
  {
    q: 'Está disponível para iPhone?',
    a: 'Por enquanto o Tempus está disponível para Android, no Google Play.',
  },
  {
    q: 'Meus dados ficam salvos se eu trocar de celular?',
    a: 'Ficam. Você entra com sua conta Google e suas matérias, tarefas e histórico de sessões são sincronizados na nuvem. É só entrar com a mesma conta no aparelho novo.',
  },
  {
    q: 'Precisa de internet?',
    a: 'Para entrar e sincronizar seu histórico, sim. O cronômetro em si roda normalmente durante a sessão, e você é avisado quando ela termina mesmo com o app em segundo plano.',
  },
  {
    q: 'Posso escolher o tempo das sessões?',
    a: 'Pode. Há atalhos de 15, 25 e 45 minutos, 1h e 1h30, qualquer duração personalizada e o modo Pomodoro (25 min de foco, 5 de pausa e pausa longa a cada 4 ciclos). Durante a sessão dá para adicionar +5 min.',
  },
  {
    q: 'Por que a tela escurece durante o foco?',
    a: 'Para cortar a tentação de mexer no celular e economizar bateria. Alguns segundos depois do play a tela apaga; para ver o tempo, é só deslizar para cima.',
  },
]

function Item({ q, a, open, onToggle }: { q: string; a: string; open: boolean; onToggle: () => void }) {
  const id = useId()
  return (
    <div
      className={`overflow-hidden rounded-2xl border transition-colors duration-200 ${
        open ? 'border-violet/30 bg-violet/[0.06]' : 'border-line bg-surface/70'
      }`}
    >
      <h3>
        <button
          type="button"
          aria-expanded={open}
          aria-controls={id}
          onClick={onToggle}
          className="flex w-full items-center justify-between gap-6 px-6 py-5 text-left"
        >
          <span className={`text-base font-bold sm:text-lg ${open ? 'text-ink' : 'text-ink/85'}`}>{q}</span>
          <span
            className={`grid h-8 w-8 shrink-0 place-items-center rounded-full border transition-all duration-300 ${
              open ? 'rotate-45 border-violet/50 bg-violet text-white' : 'border-line text-sub'
            }`}
            aria-hidden="true"
          >
            <svg viewBox="0 0 24 24" className="h-4 w-4" fill="none">
              <path d="M12 5v14M5 12h14" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" />
            </svg>
          </span>
        </button>
      </h3>
      <div
        id={id}
        role="region"
        className="grid transition-[grid-template-rows] duration-300 ease-out"
        style={{ gridTemplateRows: open ? '1fr' : '0fr' }}
      >
        <div className="overflow-hidden">
          <p className="px-6 pb-6 leading-relaxed text-sub">{a}</p>
        </div>
      </div>
    </div>
  )
}

export default function FAQSection() {
  const [open, setOpen] = useState<number | null>(0)
  return (
    <section id="faq" className="relative z-10 px-5 py-24 lg:py-32">
      <div className="mx-auto max-w-3xl">
        <SectionHeader
          eyebrow="Dúvidas"
          title={
            <>
              Perguntas <span className="text-gradient">frequentes</span>
            </>
          }
        />
        <div className="space-y-3">
          {faqs.map((f, i) => (
            <Reveal key={f.q} delay={i * 60}>
              <Item q={f.q} a={f.a} open={open === i} onToggle={() => setOpen(open === i ? null : i)} />
            </Reveal>
          ))}
        </div>
      </div>
    </section>
  )
}
