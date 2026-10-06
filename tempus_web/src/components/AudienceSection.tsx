import { Reveal, SectionHeader } from './ui'

const audiences = [
  {
    emoji: '🎯',
    title: 'ENEM e vestibular',
    body: 'Divida as matérias, cumpra a meta diária e veja a constância crescer no mapa até o dia da prova.',
    color: '#A855F7',
  },
  {
    emoji: '📚',
    title: 'Concursos',
    body: 'Rotina longa pede ritmo: Pomodoro com pausas automáticas e horas acumuladas por disciplina.',
    color: '#60A5FA',
  },
  {
    emoji: '🎓',
    title: 'Faculdade',
    body: 'Listas, trabalhos e revisões viram tarefas com tempo definido — um toque e o timer começa.',
    color: '#34D399',
  },
  {
    emoji: '🌍',
    title: 'Idiomas e cursos',
    body: 'Sessões curtas todo dia valem mais que maratonas. A sequência 🔥 te lembra de não quebrar o hábito.',
    color: '#F59E0B',
  },
]

export default function AudienceSection() {
  return (
    <section className="relative z-10 px-5 py-24 lg:py-32">
      <div className="mx-auto max-w-page">
        <SectionHeader
          eyebrow="Para quem é"
          title={
            <>
              Feito para quem <span className="text-gradient">estuda sério</span>
            </>
          }
          subtitle="Não importa a meta — o método é o mesmo: blocos de foco, pausas e constância."
        />
        <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-4">
          {audiences.map((a, i) => (
            <Reveal key={a.title} delay={i * 90}>
              <article className="card group h-full p-6 transition-all duration-300 hover:-translate-y-1" style={{ ['--c' as string]: a.color }}>
                <span
                  className="mb-5 grid h-12 w-12 place-items-center rounded-2xl text-2xl"
                  style={{ background: `${a.color}1f`, boxShadow: `inset 0 0 0 1px ${a.color}44` }}
                  aria-hidden="true"
                >
                  {a.emoji}
                </span>
                <h3 className="text-lg font-extrabold tracking-tight">{a.title}</h3>
                <p className="mt-2 text-[15px] leading-relaxed text-sub">{a.body}</p>
              </article>
            </Reveal>
          ))}
        </div>
      </div>
    </section>
  )
}
