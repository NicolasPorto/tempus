import { useEffect, useRef, useState, type CSSProperties, type ReactNode } from 'react'
import { PLAY_STORE_URL } from '../config'

/** Fades/slides children in when they scroll into view. */
export function Reveal({
  children,
  delay = 0,
  className = '',
  as: Tag = 'div',
  immediate = false,
}: {
  children: ReactNode
  delay?: number
  className?: string
  as?: 'div' | 'li' | 'section'
  /** Above-the-fold content: animate in on mount instead of waiting for the observer. */
  immediate?: boolean
}) {
  const ref = useRef<HTMLElement>(null)
  const [visible, setVisible] = useState(false)

  useEffect(() => {
    if (immediate) {
      // setTimeout (not rAF): fires even in background tabs.
      const id = window.setTimeout(() => setVisible(true), 30)
      return () => window.clearTimeout(id)
    }
    const el = ref.current
    if (!el) return
    const io = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setVisible(true)
          io.disconnect()
        }
      },
      { threshold: 0.12, rootMargin: '0px 0px -40px 0px' },
    )
    io.observe(el)
    return () => io.disconnect()
  }, [immediate])

  return (
    <Tag
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      ref={ref as any}
      className={`reveal ${visible ? 'is-visible' : ''} ${className}`}
      style={{ transitionDelay: `${delay}ms` }}
    >
      {children}
    </Tag>
  )
}

export function Logo({ size = 32 }: { size?: number }) {
  return <img src="/icon_login.svg" alt="" width={size} height={size} className="block" />
}

function AndroidIcon({ className = '' }: { className?: string }) {
  return (
    <svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true" className={className}>
      <path d="M17.6 9.48l1.84-3.18a.38.38 0 0 0-.14-.52.38.38 0 0 0-.52.14l-1.86 3.22A11.4 11.4 0 0 0 12 8.2c-1.77 0-3.43.37-4.92 1l-1.86-3.22a.38.38 0 0 0-.52-.14.38.38 0 0 0-.14.52L6.4 9.48A10.8 10.8 0 0 0 1 18h22a10.8 10.8 0 0 0-5.4-8.52zM7 15.25a1.25 1.25 0 1 1 0-2.5 1.25 1.25 0 0 1 0 2.5zm10 0a1.25 1.25 0 1 1 0-2.5 1.25 1.25 0 0 1 0 2.5z" />
    </svg>
  )
}

/** Primary download CTA — always a real link to the Play Store. */
export function PlayStoreButton({
  label = 'Baixar grátis',
  size = 'lg',
  className = '',
}: {
  label?: string
  size?: 'md' | 'lg'
  className?: string
}) {
  return (
    <a
      href={PLAY_STORE_URL}
      target="_blank"
      rel="noopener noreferrer"
      className={`btn-primary shine ${size === 'lg' ? 'px-7 py-4 text-base' : 'px-5 py-2.5 text-sm'} ${className}`}
      aria-label={`${label} no Google Play (abre em nova aba)`}
    >
      <AndroidIcon className={size === 'lg' ? 'h-6 w-6' : 'h-5 w-5'} />
      {size === 'lg' ? (
        <span className="flex flex-col items-start leading-none">
          <span className="text-[10px] font-semibold uppercase tracking-[0.14em] text-white/75">
            Disponível no Google Play
          </span>
          <span className="mt-1 text-lg font-extrabold">{label}</span>
        </span>
      ) : (
        <span>{label}</span>
      )}
    </a>
  )
}

export function SectionHeader({
  eyebrow,
  title,
  subtitle,
  align = 'center',
}: {
  eyebrow: string
  title: ReactNode
  subtitle?: ReactNode
  align?: 'center' | 'left'
}) {
  const centered = align === 'center'
  return (
    <Reveal className={`${centered ? 'mx-auto text-center' : ''} mb-14 max-w-2xl`}>
      <p className="eyebrow mb-4">{eyebrow}</p>
      <h2 className="text-[clamp(30px,5vw,48px)] font-extrabold leading-[1.08] tracking-[-0.03em]">
        {title}
      </h2>
      {subtitle && (
        <p className={`mt-5 text-lg leading-relaxed text-sub ${centered ? 'mx-auto max-w-xl' : ''}`}>
          {subtitle}
        </p>
      )}
    </Reveal>
  )
}

/** Device frame showing a real app screenshot. */
export function Phone({
  src,
  alt,
  className = '',
  glow = true,
  priority = false,
}: {
  src: string
  alt: string
  className?: string
  glow?: boolean
  priority?: boolean
}) {
  return (
    <div
      className={`relative rounded-[2.6rem] p-[7px] ${className}`}
      style={{
        background: 'linear-gradient(145deg, #4a4458, #1a1722 45%, #3a3446)',
        boxShadow: glow
          ? '0 40px 90px -20px rgba(0,0,0,0.8), 0 0 80px -10px rgba(124,58,237,0.45)'
          : '0 30px 70px -20px rgba(0,0,0,0.8)',
      }}
    >
      <div className="relative overflow-hidden rounded-[2.15rem] bg-black">
        <img
          src={src}
          alt={alt}
          width={540}
          height={1200}
          loading={priority ? 'eager' : 'lazy'}
          decoding="async"
          className="block h-auto w-full"
        />
        <div
          className="pointer-events-none absolute inset-0"
          style={{ background: 'linear-gradient(135deg, rgba(255,255,255,0.10), transparent 35%)' }}
        />
        <span className="absolute left-1/2 top-[10px] h-[11px] w-[11px] -translate-x-1/2 rounded-full bg-black" />
      </div>
    </div>
  )
}

/** The app's timer dial: 60 ticks, gradient arc and a glowing head. */
export function Dial({
  size = 220,
  progress = 0.72,
  label,
  time,
  animate = true,
  head = true,
}: {
  size?: number
  progress?: number
  label?: string
  time?: string
  animate?: boolean
  head?: boolean
}) {
  const r = 44
  const c = 2 * Math.PI * r
  const angle = -90 + progress * 360
  const hx = 50 + r * Math.cos((angle * Math.PI) / 180)
  const hy = 50 + r * Math.sin((angle * Math.PI) / 180)
  return (
    <div className="relative" style={{ width: size, height: size }}>
      <svg viewBox="0 0 100 100" className="h-full w-full overflow-visible" aria-hidden="true">
        <defs>
          <linearGradient id="dialGrad" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0" stopColor="#A855F7" />
            <stop offset="1" stopColor="#60A5FA" />
          </linearGradient>
          <filter id="dialGlow" x="-50%" y="-50%" width="200%" height="200%">
            <feGaussianBlur stdDeviation="2.4" />
          </filter>
        </defs>
        {Array.from({ length: 60 }, (_, i) => {
          const a = (i / 60) * Math.PI * 2 - Math.PI / 2
          const major = i % 5 === 0
          const r0 = 37.5
          const r1 = r0 - (major ? 4 : 2)
          return (
            <line
              key={i}
              x1={50 + r0 * Math.cos(a)}
              y1={50 + r0 * Math.sin(a)}
              x2={50 + r1 * Math.cos(a)}
              y2={50 + r1 * Math.sin(a)}
              stroke="white"
              strokeOpacity={major ? 0.35 : 0.14}
              strokeWidth={major ? 0.9 : 0.6}
              strokeLinecap="round"
            />
          )
        })}
        <circle cx="50" cy="50" r={r} fill="none" stroke="#1f1830" strokeWidth="4.5" />
        <circle
          cx="50"
          cy="50"
          r={r}
          fill="none"
          stroke="url(#dialGrad)"
          strokeWidth="9"
          strokeOpacity="0.45"
          strokeDasharray={c}
          strokeDashoffset={c * (1 - progress)}
          transform="rotate(-90 50 50)"
          filter="url(#dialGlow)"
        />
        <circle
          cx="50"
          cy="50"
          r={r}
          fill="none"
          stroke="url(#dialGrad)"
          strokeWidth="4.5"
          strokeLinecap="round"
          strokeDasharray={c}
          strokeDashoffset={c * (1 - progress)}
          transform="rotate(-90 50 50)"
          style={
            animate
              ? ({
                  '--len': `${c}`,
                  '--off': `${c * (1 - progress)}`,
                  animation: 'dial-sweep 1.8s cubic-bezier(0.22,1,0.36,1) both',
                } as CSSProperties)
              : undefined
          }
        />
        {head && <circle cx={hx} cy={hy} r="3.6" fill="white" />}
        {head && <circle cx={hx} cy={hy} r="1.7" fill="#A855F7" />}
      </svg>
      {(label || time) && (
        <div className="absolute inset-0 flex flex-col items-center justify-center">
          {label && (
            <span className="text-[0.62em] font-extrabold tracking-[0.25em] text-violet-soft" style={{ fontSize: size * 0.05 }}>
              {label}
            </span>
          )}
          {time && (
            <span
              className="font-light tabular-nums tracking-tight text-ink"
              style={{ fontSize: size * 0.2, lineHeight: 1.05 }}
            >
              {time}
            </span>
          )}
        </div>
      )}
    </div>
  )
}
