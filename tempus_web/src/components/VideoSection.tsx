import { useEffect, useRef } from 'react'
import { PlayStoreButton, Reveal } from './ui'

export default function VideoSection() {
  const ref = useRef<HTMLVideoElement>(null)

  // Only play while on screen (saves battery and data on mobile).
  useEffect(() => {
    const v = ref.current
    if (!v) return
    const reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches
    const io = new IntersectionObserver(
      ([e]) => {
        if (e.isIntersecting && !reduce) v.play().catch(() => {})
        else v.pause()
      },
      { threshold: 0.35 },
    )
    io.observe(v)
    return () => io.disconnect()
  }, [])

  return (
    <section id="video" className="relative z-10 px-5 py-24 lg:py-32">
      <div className="mx-auto grid max-w-page items-center gap-14 rounded-[2.5rem] border border-line bg-gradient-to-br from-[#1a1428] to-[#0d0b16] p-8 sm:p-12 lg:grid-cols-2 lg:p-16">
        <div className="text-center lg:text-left">
          <Reveal>
            <p className="eyebrow mb-4">Em 15 segundos</p>
            <h2 className="text-[clamp(32px,5vw,52px)] font-extrabold leading-[1.05] tracking-[-0.035em]">
              Escolha. Dê o play.
              <br />
              <span className="text-gradient">Evolua.</span>
            </h2>
          </Reveal>
          <Reveal delay={100}>
            <p className="mx-auto mt-6 max-w-md text-lg leading-relaxed text-sub lg:mx-0">
              Veja o Tempus em ação: do primeiro toque no timer até as conquistas desbloqueadas.
            </p>
          </Reveal>
          <Reveal delay={180}>
            <div className="mt-9 flex justify-center lg:justify-start">
              <PlayStoreButton />
            </div>
          </Reveal>
        </div>

        <Reveal delay={120} className="flex justify-center">
          <div
            className="relative w-[min(70vw,300px)] rounded-[2.6rem] p-[7px]"
            style={{
              background: 'linear-gradient(145deg, #4a4458, #1a1722 45%, #3a3446)',
              boxShadow: '0 40px 90px -20px rgba(0,0,0,0.8), 0 0 90px -10px rgba(124,58,237,0.55)',
            }}
          >
            <video
              ref={ref}
              className="block aspect-[9/16] w-full rounded-[2.15rem] bg-black object-cover"
              src="/media/tempus-15s.mp4"
              poster="/media/tempus-15s-poster.jpg"
              muted
              loop
              playsInline
              preload="metadata"
              aria-label="Vídeo de demonstração do Tempus, 15 segundos, sem áudio"
            />
          </div>
        </Reveal>
      </div>
    </section>
  )
}
