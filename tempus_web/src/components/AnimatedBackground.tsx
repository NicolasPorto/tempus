import { useEffect, useRef } from 'react'

interface Orb {
  x: number
  y: number
  radius: number
  color: string
  speedX: number
  speedY: number
  phase: number
}

export default function AnimatedBackground() {
  const canvasRef = useRef<HTMLCanvasElement>(null)

  useEffect(() => {
    const canvas = canvasRef.current
    if (!canvas) return
    const ctx = canvas.getContext('2d')
    if (!ctx) return

    const orbs: Orb[] = [
      { x: 0, y: 0, radius: 180, color: 'rgba(90, 20, 200, 0.12)', speedX: 0.3, speedY: 0.2, phase: 0 },
      { x: 0, y: 0, radius: 220, color: 'rgba(60, 30, 180, 0.10)', speedX: 0.2, speedY: 0.35, phase: 1.2 },
      { x: 0, y: 0, radius: 150, color: 'rgba(43, 127, 255, 0.09)', speedX: 0.4, speedY: 0.15, phase: 2.4 },
      { x: 0, y: 0, radius: 200, color: 'rgba(172, 70, 255, 0.08)', speedX: 0.15, speedY: 0.4, phase: 3.6 },
      { x: 0, y: 0, radius: 130, color: 'rgba(50, 10, 150, 0.11)', speedX: 0.35, speedY: 0.25, phase: 4.8 },
      { x: 0, y: 0, radius: 160, color: 'rgba(30, 50, 180, 0.08)', speedX: 0.25, speedY: 0.3, phase: 0.6 },
    ]

    let animationId: number
    let t = 0

    const resize = () => {
      canvas.width = window.innerWidth
      canvas.height = window.innerHeight
    }

    resize()
    window.addEventListener('resize', resize)

    const draw = () => {
      if (!ctx || !canvas) return
      ctx.clearRect(0, 0, canvas.width, canvas.height)

      const cx = canvas.width / 2
      const cy = canvas.height / 2

      orbs.forEach((orb, i) => {
        const angle = t * orb.speedX + orb.phase
        const x = cx + Math.cos(angle) * canvas.width * 0.35
        const angle2 = t * orb.speedY + orb.phase + 0.5
        const y = cy + Math.sin(angle2) * canvas.height * 0.35

        ctx.save()
        ctx.filter = `blur(${orb.radius * 0.4}px)`
        ctx.beginPath()
        ctx.arc(x, y, orb.radius, 0, Math.PI * 2)
        ctx.fillStyle = orb.color
        ctx.fill()
        ctx.restore()
      })

      t += 0.008
      animationId = requestAnimationFrame(draw)
    }

    draw()

    return () => {
      cancelAnimationFrame(animationId)
      window.removeEventListener('resize', resize)
    }
  }, [])

  return (
    <canvas
      ref={canvasRef}
      style={{
        position: 'fixed',
        top: 0,
        left: 0,
        width: '100%',
        height: '100%',
        zIndex: 0,
        pointerEvents: 'none',
      }}
    />
  )
}
