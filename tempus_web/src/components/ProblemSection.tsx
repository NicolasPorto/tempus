import { Reveal } from './ui'

const notifs = [
  { icon: '💬', title: 'Grupo da sala', body: 'kkkkk viu isso??', color: '#25D366', x: '4%', y: '0%', r: -6 },
  { icon: '▶️', title: 'Novo vídeo', body: 'Você vai amar esse', color: '#FF0033', x: '18%', y: '17%', r: 4 },
  { icon: '❤️', title: 'Alguém curtiu', body: 'sua foto · agora', color: '#E1306C', x: '0%', y: '36%', r: -3 },
  { icon: '🎮', title: 'Sua energia encheu!', body: 'Volte e jogue', color: '#7C3AED', x: '16%', y: '55%', r: 5 },
  { icon: '🔔', title: '+99 notificações', body: 'toque para ver', color: '#F59E0B', x: '4%', y: '74%', r: -4 },
]

export default function ProblemSection() {
  return (
    <section className="relative z-10 overflow-x-clip px-5 py-24 lg:py-32">
      <div className="mx-auto grid max-w-page items-center gap-14 lg:grid-cols-2">
        <Reveal className="relative order-2 h-[420px] lg:order-1" >
          <div className="absolute inset-0">
            {notifs.map((n, i) => (
              <div
                key={n.title}
                className="absolute w-[min(82%,340px)]"
                style={{
                  left: n.x,
                  top: n.y,
                  ['--r' as string]: `${n.r}deg`,
                  animation: `notif-in 0.6s cubic-bezier(0.34,1.56,0.64,1) ${i * 0.12}s both, float ${6 + i}s ease-in-out ${i * 0.4}s infinite`,
                }}
              >
                <div className="flex items-center gap-3 rounded-2xl border border-white/[0.07] bg-[#262330]/95 p-3.5 shadow-[0_20px_40px_-12px_rgba(0,0,0,0.7)]">
                  <span
                    className="grid h-11 w-11 shrink-0 place-items-center rounded-xl text-xl"
                    style={{ background: n.color }}
                    aria-hidden="true"
                  >
                    {n.icon}
                  </span>
                  <div className="min-w-0 flex-1">
                    <div className="flex items-baseline justify-between gap-2">
                      <p className="truncate text-[15px] font-extrabold">{n.title}</p>
                      <span className="text-[11px] font-semibold text-muted">agora</span>
                    </div>
                    <p className="truncate text-sm font-medium text-sub">{n.body}</p>
                  </div>
                </div>
              </div>
            ))}
          </div>
          {/* the "do not disturb" seal */}
          <div className="absolute bottom-2 right-0 flex items-center gap-2 rounded-full border border-violet/40 bg-bg/90 px-4 py-2 text-sm font-bold text-violet-soft shadow-lg backdrop-blur sm:right-6">
            <span className="h-2 w-2 rounded-full bg-violet shadow-[0_0_10px_#A855F7]" />
            Modo foco: notificações ficam pra depois
          </div>
        </Reveal>

        <div className="order-1 text-center lg:order-2 lg:text-left">
          <Reveal>
            <p className="eyebrow mb-4">Seja sincero</p>
            <h2 className="text-[clamp(34px,5.5vw,58px)] font-extrabold leading-[1.02] tracking-[-0.035em]">
              Estudou 3 horas…
              <br />
              <span className="text-[#FF5A5F]">ou ficou 3h no celular?</span>
            </h2>
          </Reveal>
          <Reveal delay={120}>
            <p className="mx-auto mt-7 max-w-lg text-lg leading-relaxed text-sub lg:mx-0">
              Cada notificação custa minutos de concentração. No Tempus, quando o timer começa,
              a tela <strong className="text-ink">escurece sozinha</strong> e só volta quando você
              desliza para cima. Sem tentação, sem rolagem infinita — só você e a matéria.
            </p>
          </Reveal>
        </div>
      </div>
    </section>
  )
}
